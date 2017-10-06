defmodule NifNotLoadedError do
  defexception message: "nif not loaded"
end

defmodule RustySecretsNif do
  use Rustler, otp_app: :rusty_secrets_nif, crate: "rustysecretsnif"

  def new(size), do: err()
  def get(buffer, idx), do: err()
  def set(buffer, idx, value), do: err()

  defp err() do
    throw NifNotLoadedError
  end

end
