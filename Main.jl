using GPUCompiler
using LLVM

struct Arduino <: GPUCompiler.AbstractCompilerTarget end

GPUCompiler.llvm_triple(::Arduino) = "avr-unknown-unknown"
GPUCompiler.runtime_slug(::GPUCompiler.CompilerJob{Arduino}) = "native_avr-jl_blink"

struct ArduinoParams <: GPUCompiler.AbstractCompilerParams end

module StaticRuntime
signal_exception() = return
malloc(_) = C_NULL
report_oom(_) = return
report_exception(_) = return
report_exception_name(_) = return
report_exception_frame(_, _, _, _) = return
end

GPUCompiler.runtime_module(::GPUCompiler.CompilerJob{<:Any,ArduinoParams}) = StaticRuntime
GPUCompiler.runtime_module(::GPUCompiler.CompilerJob{Arduino}) = StaticRuntime
GPUCompiler.runtime_module(::GPUCompiler.CompilerJob{Arduino,ArduinoParams}) = StaticRuntime

function native_job(@nospecialize(func), @nospecialize(types))
  @info "Making compiler job for '$func$types'"
  source = GPUCompiler.methodinstance(typeof(func), Base.to_tuple_type(types))
  config = GPUCompiler.CompilerConfig(Arduino(), ArduinoParams(); kernel=false, name=String(nameof(func)))
  return GPUCompiler.CompilerJob(source, config)
end

function build(mod::Module)
  GPUCompiler.reset_runtime()
  GPUCompiler.JuliaContext() do _
    GPUCompiler.compile(:obj, native_job(mod.main, ()))[1]
  end
end

function write_out(mod)
  obj = build(mod)
  write("out.o", obj)
end


function build_dump(mod)
  obj = build(mod)
  mktemp() do path, io
    write(io, obj)
    flush(io)
    str = read(`avr-objdump -dr $path`, String)
  end |> print
end

module Blink
const DDRB = Ptr{UInt8}(36) # 0x25, but julia only provides conversion methods for `Int`
const PORTB = Ptr{UInt8}(37) # 0x26
const DDB1 = 0b00000010
const PORTB1 = 0b00000010
const PORTB_none = 0b00000000 # We don't need any other pin - set everything low

function volatile_store!(x::Ptr{UInt8}, v::UInt8)
  return Base.llvmcall(
    """
    %ptr = inttoptr i64 %0 to i8*
    store volatile i8 %1, i8* %ptr, align 1
    ret void
    """,
    Cvoid,
    Tuple{Ptr{UInt8},UInt8},
    x,
    v
  )
end

function keep(x)
  return Base.llvmcall(
    """
    call void asm sideeffect "", "X,~{memory}"(i16 %0)
    ret void
    """,
    Cvoid,
    Tuple{Int16},
    x
  )
end

function main()
  volatile_store!(DDRB, DDB1)

  while true
    volatile_store!(PORTB, PORTB1) # enable LED

    for y in Int16(1):Int16(30000)
      keep(y)
    end

    volatile_store!(PORTB, PORTB_none) # disable LED

    for y in Int16(1):Int16(30000)
      keep(y)
    end
  end
end
end

build_dump(Blink)
write_out(Blink)
