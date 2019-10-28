# KeyX

Elixir library for Shamir's Secret Sharing (SSS) algorithm. Now implemented in native Elixir following Hashicorp Vault's implementation of SSS in order to provide a byte-compatible but distinct implementation of Shamir's method. 

## Implementation Details

This version follows Vault's usage of a new polynomial in GF(2^8) space for each byte of the given secret byte array (binary). In the returned shares, y values for each secret byte are concatenated into a single byte array with a single trailing x value at the end (`length(secret) == length(share[n]) + 1`). This could be considered the 'specification' of the return secret shares (rather than separate {x,y} points).

The reasoning for the extra work of following another Shamir implementation is to ensure multiple libraries or code bases can decode secret shares once split. Note that the Elixir library returns the raw binary, whereas the Go version generally hex encode the binary array.  

Documentation can be found at [https://hexdocs.pm/keyx](https://hexdocs.pm/keyx).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `keyx` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:keyx, "~> 0.4.1"}
  ]
end
```
