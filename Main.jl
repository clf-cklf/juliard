using GPUCompiler
using LLVM

struct Arduino <: GPUCompiler.AbstractCompilerTarget end

GPUCompiler.llvm_triple(::Arduino) = "avr-unknown-unknown"
GPUCompiler.runtime_slug(::GPUCompiler.CompilerJob{Arduino}) = "native_avr-jl_blink"

struct ArduinoParams <: GPUCompiler.AbstractCompilerParams end

module StaticRuntime
signal_exception() = return
malloc(sz) = C_NULL
report_oom(sz) = return
report_exception(ex) = return
report_exception_name(ex) = return
report_exception_frame(idx, func, file, line) = return
end

GPUCompiler.runtime_module(::GPUCompiler.CompilerJob{<:Any,ArduinoParams}) = StaticRuntime
GPUCompiler.runtime_module(::GPUCompiler.CompilerJob{Arduino}) = StaticRuntime
GPUCompiler.runtime_module(::GPUCompiler.CompilerJob{Arduino,ArduinoParams}) = StaticRuntime

function native_job(@nospecialize(func), @nospecialize(types))
@info "Making compiler job for '$func($types)'"
