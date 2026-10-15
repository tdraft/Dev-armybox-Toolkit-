mod applets;
mod toolkit;

use core::ffi::c_int;
use std::ffi::CString;
use std::os::unix::ffi::OsStrExt;

fn main() {
    let arguments: Vec<CString> = std::env::args_os()
        .map(|argument| {
            CString::new(argument.as_os_str().as_bytes())
                .expect("process arguments cannot contain NUL bytes")
        })
        .collect();
    let argv: Vec<*const u8> = arguments
        .iter()
        .map(|argument| argument.as_ptr().cast())
        .collect();
    let argc = argv.len() as c_int;

    let status = toolkit::dispatch(argc, argv.as_ptr());
    let status = if status == 0 {
        applets::dispatch(argc, argv.as_ptr())
    } else {
        status
    };

    std::process::exit(status);
}
