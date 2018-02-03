defmodule MobileMarkdown.AWSSigV4.Credential do
  defstruct [:host, :policy, :x_amz_credential, :x_amz_date, :x_amz_algorithm, :x_amz_signature]
end
