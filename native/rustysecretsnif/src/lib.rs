#[macro_use] extern crate rustler;
#[macro_use] extern crate rustler_codegen;
#[macro_use] extern crate lazy_static;

use rustler::{NifEnv, NifTerm, NifResult, NifEncoder};
use std::sync::RwLock;
use rustler::resource::ResourceArc;

extern crate rusty_secrets;
use rusty_secrets::{generate_shares};

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
		// ("new", 1, buffer_new),
		("generate_shares", 3, shamir_generate_shares),
		// ("set", 3, buffer_set),
	],
    None
}

struct Buffer {
	data: RwLock<Vec<u8>>,
}


// pub fn buffer_new<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
// 	// The NIF should have a single argument provided, namely
// 	// the size of the buffer we want to create.
// 	let buffer_size: usize = args[0].decode()?;
//
// 	// Create the actual buffer and initialize it with zeroes.
// 	let mut buffer = Vec::with_capacity(buffer_size);
// 	for _i in 0..buffer_size {
//         buffer.push(0);
//     }
//
// 	// Make the actual struct
// 	let buffer_struct = Buffer {
// 		data: RwLock::new(buffer),
// 	};
//
// 	// Return it!
// 	Ok((atoms::ok(), ResourceArc::new(buffer_struct)).encode(env))
// }

pub fn shamir_generate_shares<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
	// let buffer: ResourceArc<Buffer> = args[0].decode()?;
	let shamir_k: u8 = args[0].decode()?;
	let shamir_n: u8 = args[1].decode()?;
	let shamir_secret: Vec<u8> = args[2].decode()?;

    // let buf = buffer.data.read().unwrap();
    println!("generate_shares: {k} of {n} - {sec:?}", k=shamir_k, n=shamir_n, sec=shamir_secret);

	match generate_shares(shamir_k, shamir_n, &shamir_secret) {
        Ok(shares) =>
            Ok((atoms::ok(), shares).encode(env)),
        Err(_) =>
            Ok(atoms::error().encode(env)),
    }
}

// pub fn buffer_set<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
// 	// let buffer: ResourceArc<Buffer> = args[0].decode()?;
// 	let offset: usize = args[1].decode()?;
// 	let byte: u8 = args[2].decode()?;
//
// 	// buffer.data.write().unwrap()[offset] = byte;
// 	// Ok(byte.encode(env))
//     Ok((atoms::ok()).encode(env))
// }
