defmodule NifNotLoadedError do
  defexception message: "nif not loaded"
end

defmodule RustySecretsNif do
  use Rustler, otp_app: :keyx, crate: "rustysecretsnif"

  # def new(size), do: err()
  def generate_shares(k, n, secret), do: err()
  # def set(buffer, idx, value), do: err()

  defp err() do
    throw NifNotLoadedError
  end

end
