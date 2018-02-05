defmodule MobileMarkdownWeb.FakeUploadView do
  use MobileMarkdownWeb, :view

  def render("success.xml", _) do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <PostResponse><Location>http://example.bucket.com.amazonaws.com/example.png</Location><Bucket>example.bucket.com</Bucket><Key>example.png</Key><ETag>"9708765afd6c25f59ff10ddf171848df"</ETag></PostResponse>
    """
  end
end
