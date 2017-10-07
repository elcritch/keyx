defmodule Keyx do
  @moduledoc """
  Documentation for Keyx.
  """

  @doc """
  Generate secret shares using Shamir's Secret Sharing alrgorithm.

  ## Parameters

    - K: specifies the number of shares necessary to recover the secret.
    - N: is the identifier of the share and varies between 1 and n where n is the total number of generated shares.
    - Secret: Binary (String) of raw secret to split `N` ways, requiring `K` shares to recover. 

    
  ## Examples

      iex> Keyx.generate_shares(1,2, "super duper secret")
      {:ok, ["1-1-c3VwZXIgZHVwZXIgc2VjcmV0", "1-2-c3VwZXIgZHVwZXIgc2VjcmV0"]}

  """
  defdelegate generate_shares(k,n,shares), to: RustySecretsNif


  @doc """
  Recover secrets from an appropriate number of shares. Must be equal or greater than the `K` parameters. 

  ## Parameters

    - Shares: List of shares (Base64 encoding) containing information about the share, and if signed, the signature.

  ## Examples

      iex> Keyx.recover_secret(["1-2-c3VwZXIgZHVwZXIgc2VjcmV0", "1-2-c3VwZXIgZHVwZXIgc2VjcmV0"])
      {:ok, "super duper secret"}

  """
  defdelegate recover_secret(shares), to: RustySecretsNif

end
