#[macro_use] extern crate rustler;
// #[macro_use] extern crate rustler_codegen;
#[macro_use] extern crate lazy_static;

use rustler::{NifEnv, NifTerm, NifResult, NifEncoder};

extern crate rusty_secrets;
use rusty_secrets::{generate_shares, recover_secret};

mod atoms {
    rustler_atoms! {
        atom ok;
        atom error;
    }
}

rustler_export_nifs! {
    "Elixir.RustySecretsNif",
	[
		("generate_shares", 3, shamir_generate_shares),
		("recover_secret", 1, shamir_recover_secret),
	],
    None
}

pub fn shamir_generate_shares<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
	// let buffer: ResourceArc<Buffer> = args[0].decode()?;
	let shamir_k: u8 = args[0].decode()?;
	let shamir_n: u8 = args[1].decode()?;
    let shamir_secret: String = args[2].decode()?;

    println!("rust generate_shares: {k} of {n} -- {sec:?}", k=shamir_k, n=shamir_n, sec=shamir_secret);

    // let buf = buffer.data.read().unwrap();

	match generate_shares(shamir_k, shamir_n, &shamir_secret.into_bytes()) {
        Ok(shares) =>
            Ok((atoms::ok(), shares).encode(env)),
        Err(_) =>
            Ok(atoms::error().encode(env)),
    }
}

pub fn shamir_recover_secret<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {

    let shares: Vec<String> = args[0].decode()?;

    println!("rust recover_secret: {k:?} ", k=shares);

    match recover_secret(shares) {
        Ok(secret) => {
            let secret_binary = String::from_utf8(secret).unwrap();
            Ok((atoms::ok(), secret_binary).encode(env))
        },
        Err(e) => {
            Ok((atoms::error(), e.to_string() ).encode(env))
        }
    }
}
