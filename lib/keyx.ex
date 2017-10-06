defmodule Keyx do
  @moduledoc """
  Documentation for Keyx.
  """

  # proper test --       {:ok, ["1-1-c3VwZXIgZHVwZXIgc2VjcmV0", "1-2-c3VwZXIgZHVwZXIgc2VjcmV0"]}

  @doc """
  Generate secret shares using Shamir's Secret Sharing alrgorithm.

  ## Examples

      iex> Keyx.generate_shares(1,2, "super duper secret")
      {:ok, ["1-1-c3VwZXIgZHVwZXIgc2VjcmV0", "2-2-c3VwZXIgZHVwZXIgc2VjcmV0"]}

  """
  defdelegate generate_shares(k,n,shares), to: RustySecretsNif


  @doc """
  Hello world.

  ## Examples

      iex> Keyx.recover_secret(["1-1-c3VwZXIgZHVwZXIgc2VjcmV0", "1-2-c3VwZXIgZHVwZXIgc2VjcmV0"])
      {:ok, "super duper secret"}

  """
  defdelegate recover_secret(shares), to: RustySecretsNif

end
