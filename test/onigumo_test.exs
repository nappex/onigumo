defmodule OnigumoTest do
  use ExUnit.Case
  import Mox

  @url "http://onigumo.org/hello.html"
  @filename "body.html"
  @testfile_with_urls "urls.txt"

  setup(:verify_on_exit!)

  test("download") do
    expect(
      HTTPoisonMock,
      :get!,
      fn url ->
        %HTTPoison.Response{
          status_code: 200,
          body: "Body from: #{url}\n"
        }
      end
    )

    assert(:ok == Onigumo.download(HTTPoisonMock, @url))
    assert("Body from: #{@url}\n" == File.read!(@filename))
  end


  @tag :tmp_dir
  test("load URL from file", %{tmp_dir: tmp_dir}) do
    filepath = Path.join(tmp_dir, @testfile_with_urls)
    content = @url <> " \n"
    File.write!(filepath, content)

    expected = [@url]
    assert(expected == Onigumo.load_urls(filepath))
  end

end
