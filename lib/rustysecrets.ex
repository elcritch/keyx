defmodule NifNotLoadedError do
  defexception message: "nif not loaded"
end

defmodule RustySecretsNif do
  use Rustler, otp_app: :keyx, crate: "rustysecretsnif"

  def generate_shares(_k, _n, _secret), do: err()
  def recover_secret(_shares), do: err()

  defp err() do
    throw NifNotLoadedError
  end

end
