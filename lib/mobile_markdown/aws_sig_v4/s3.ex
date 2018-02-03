defmodule MobileMarkdown.AWSSigV4.S3 do
  @moduledoc """
  Helper functions for generating Sig4 values for accessing the S3 service.
  """

  def policy(start_time, expires_in, conditions) do
    start_time
    |> expires_at(expires_in)
    |> policy(conditions)
  end

  def date_string(datetime) do
    datetime |> Date.to_iso8601(:basic) |> Kernel.<>("T000000Z")
  end

  defp expires_at(datetime, expires_in) do
    datetime
    |> DateTime.truncate(:second)
    |> DateTime.to_naive()
    |> NaiveDateTime.add(expires_in)
    |> NaiveDateTime.to_iso8601()
    |> Kernel.<>("Z")
  end

  defp policy(expiry, conditions) do
    %{"expiration" => expiry, "conditions" => conditions}
    |> Poison.encode!()
    |> Base.encode64()
  end
end
