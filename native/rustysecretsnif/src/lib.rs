#[macro_use] extern crate rustler;
#[macro_use] extern crate rustler_codegen;
#[macro_use] extern crate lazy_static;

use rustler::{NifEnv, NifTerm, NifResult, NifEncoder};
use std::sync::RwLock;
use rustler::resource::ResourceArc;

mod atoms {
    rustler_atoms! {
        atom ok;
        atom error;
        //atom __true__ = "true";
        //atom __false__ = "false";
    }
}

rustler_export_nifs! {
    "Elixir.RustySecretsNif",
    // The functions we want to export.
	// They consist of a tuple containing the function name,
	// function arity, and the Rust function itself.
	[
		("new", 1, buffer_new),
		("get", 2, buffer_get),
		("set", 3, buffer_set),
	],
	// Our on_load function. Will get called on load.
	Some(on_load)
}

struct Buffer {
	data: RwLock<Vec<u8>>,
}


// The `'a` in this function definition is something called a lifetime.
// This will inform the Rust compiler of how long different things are
// allowed to live. Don't worry too much about this, as this will be the
// exact same for most function definitions.
pub fn on_load<'a>(env: NifEnv<'a>, _load_info: NifTerm<'a>) -> bool {
	// This macro will take care of defining and initializing a new resource
	// object type.
	resource_struct_init!(Buffer, env);
	true
}

pub fn buffer_new<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
	// The NIF should have a single argument provided, namely
	// the size of the buffer we want to create.
	let buffer_size: usize = args[0].decode()?;

	// Create the actual buffer and initialize it with zeroes.
	let mut buffer = Vec::with_capacity(buffer_size);
	for _i in 0..buffer_size {
        buffer.push(0);
    }

	// Make the actual struct
	let buffer_struct = Buffer {
		data: RwLock::new(buffer),
	};

	// Return it!
	Ok((atoms::ok(), ResourceArc::new(buffer_struct)).encode(env))
}

pub fn buffer_get<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
	let buffer: ResourceArc<Buffer> = args[0].decode()?;
	let offset: usize = args[1].decode()?;

    let buf = buffer.data.read().unwrap();

	match buf.get(offset) {
        Some(byte) =>
            Ok(byte.encode(env)),
        None =>
            Ok(atoms::error().encode(env)),
    }
}

pub fn buffer_set<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
	let buffer: ResourceArc<Buffer> = args[0].decode()?;
	let offset: usize = args[1].decode()?;
	let byte = args[2].decode()?;

	buffer.data.write().unwrap()[offset] = byte;
	Ok(byte.encode(env))
}
