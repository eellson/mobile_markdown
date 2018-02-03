defmodule MobileMarkdown.AWSSigV4.S3 do
  @moduledoc """
  Helper functions for generating Sig4 values for accessing the S3 service.
  """

  @doc """
  Outputs base64-encoded policy based upon given inputs.

  For example, if we were to use inputs like the following:

      start_time = %DateTime{year: 2018, month: 02, day: 02, hour: 00, minute: 00, second: 00, ...}
      expires_in = 30
      conditions = [["starts-with", "$key", ""]]

  `expires_at` will be calculated to be 30 seconds later than `start_time`, with
  the policy looking like:

      %{"expiration" => "2018-02-02T000030Z", "conditions" => [["starts-with", "$key", ""]]}

  This is then encoded, and returned as:

      "eyJleHBpcmF0aW9uIjoiMjAxOC0wMi0wMlQwMDAwMzBaIiwiY29uZGl0aW9ucyI6W1sic3RhcnRzLXdpdGgiLCIka2V5IiwiIl1dfQ=="
  """
  @spec policy(DateTime.t(), integer(), list()) :: String.t()
  def policy(start_time, expires_in, conditions) do
    start_time
    |> expires_at(expires_in)
    |> policy(conditions)
  end

  @doc """
  Returns date string based on given %DateTime{}.

  This function drops any time data, leaving just the date, and appending a
  string representing midnight that day.
  """
  @spec date_string(DateTime.t()) :: String.t()
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
