defmodule KeyX do
  @moduledoc """
  Documentation for KeyX.
  """

  @doc """
  Generate secret shares using Shamir's Secret Sharing alrgorithm.

  ## Parameters

    - k: specifies the number of shares necessary to recover the secret.
    - n: is the identifier of the share and varies between 1 and n where n is the total number of generated shares.
    - secret: Binary (String) of raw secret to split `N` ways, requiring `K` shares to recover.
    - base: Encoding for binary. Can be :raw, :base16, :base32, :base64.
    - base_opts: Options to pass to Base.baseXX encoding functions.

  ## Examples

      iex> KeyX.generate_shares(2,2, "super duper secret")
      {:ok,
       [<<186, 234, 192, 2, 71, 115, 247, 148, 55, 75, 121, 181, 11, 109, 136, 102,
          91, 211, 158>>,
        <<174, 39, 169, 16, 201, 53, 245, 20, 59, 53, 134, 93, 172, 231, 45, 44, 42,
          133, 137>>]}

  """
  @spec generate_shares(k :: pos_integer, n :: pos_integer, secret :: String.t, base :: atom, base_opts :: list(atom) ) :: nonempty_list(binary)
  def generate_shares(k,n,secret, base \\ :raw, base_opts \\ []) do

    shares = generate_shares!(k,n,secret)

    encoded_shares = case base do
      :raw -> shares
      :base16 -> shares |> Enum.map(&(Base.encode16(&1, base_opts)))
      :base32 -> shares |> Enum.map(&(Base.encode32(&1, base_opts)))
      :base64 -> shares |> Enum.map(&(Base.encode64(&1, base_opts)))
    end

    {:ok, encoded_shares}
  end

  @doc """
  Same as `generate_shares` but no extra error handlineg.

  ## Parameters

  - k: specifies the number of shares necessary to recover the secret.
  - n: is the identifier of the share and varies between 1 and n where n is the total number of generated shares.
  - secret: Binary (String) of raw secret to split `N` ways, requiring `K` shares to recover.

  """
  defdelegate generate_shares!(k,n,secret), to: KeyX.Shamir, as: :split_secret

  @doc """
  Recover secrets from an appropriate number of shares. Must be equal or greater than the `K` parameters.

  ## Parameters

    - Shares: List of shares (Base64 encoding) containing information about the share, and if signed, the signature.

  ## Examples

      iex> KeyX.recover_secret(["1-2-c3VwZXIgZHVwZXIgc2VjcmV0", "1-2-c3VwZXIgZHVwZXIgc2VjcmV0"])
      {:ok, "super duper secret"}

  """
  @spec recover_secret(shares :: nonempty_list(String.t) ) :: binary
  def recover_secret(shares), do: {:ok, recover_secret!(shares)}

  @doc """
  Same as `recover_secret` but no extra error handlineg.

  ## Parameters

    - Shares: List of shares (Base64 encoding) containing information about the share, and if signed, the signature.

  """
  defdelegate recover_secret!(shares), to: KeyX.Shamir, as: :recover_secret

end
