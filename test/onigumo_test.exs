defmodule OnigumoTest do
  use ExUnit.Case
  import Mox

  @urls [
    "http://onigumo.local/hello.html",
    "http://onigumo.local/bye.html"
  ]
  @output_path "body.html"

  setup(:verify_on_exit!)

  @tag :tmp_dir
  test("download a URL", %{tmp_dir: tmp_dir}) do
    expect(HTTPoisonMock, :get!, &get!/1)

    url = Enum.at(@urls, 0)
    tmp_path = Path.join(tmp_dir, @output_path)
    result = Onigumo.download(url, HTTPoisonMock, tmp_path)
    assert(result == :ok)

    read_content = File.read!(tmp_path)
    expected_content = body(url)
    assert(read_content == expected_content)
  end

  @tag :tmp_dir
  test("download URLs from the input file", %{tmp_dir: tmp_dir}) do
    expect(HTTPoisonMock, :get!, length(@urls), &get!/1)

    env_path = Application.get_env(:onigumo, :input_path)
    input_path = Path.join(tmp_dir, env_path)
    content = Enum.map(@urls, &(&1 <> "\n")) |> Enum.join()
    File.write!(input_path, content)

    output_path = Path.join(tmp_dir, @output_path)
    Enum.map(@urls, fn url ->
      result = Onigumo.download(url, HTTPoisonMock, output_path)
      assert(result == :ok)
    end)

    last_url = Enum.at(@urls, -1)
    read_content = File.read!(output_path)
    expected_content = body(last_url)
    assert(read_content == expected_content)
  end

  @tag :tmp_dir
  test("load a single URL from a file", %{tmp_dir: tmp_dir}) do
    input_urls = Enum.slice(@urls, 0, 1)

    env_path = Application.get_env(:onigumo, :input_path)
    tmp_path = Path.join(tmp_dir, env_path)
    content = prepare_input(input_urls)
    File.write!(tmp_path, content)

    loaded_urls = Onigumo.load_urls(tmp_path)
    assert(loaded_urls == input_urls)
  end

  @tag :tmp_dir
  test("load multiple URLs from a file", %{tmp_dir: tmp_dir}) do
    env_path = Application.get_env(:onigumo, :input_path)
    tmp_path = Path.join(tmp_dir, env_path)
    content = prepare_input(@urls)
    File.write!(tmp_path, content)

    urls = Onigumo.load_urls(tmp_path)
    assert(urls == @urls)
  end

  defp get!(url) do
    %HTTPoison.Response{
      status_code: 200,
      body: body(url)
    }
  end

  defp prepare_input(urls) do
    Enum.map(urls, &(&1 <> "\n"))
    |> Enum.join()
  end

  defp body(url) do
    "Body from: #{url}\n"
  end
end
