defmodule Onigumo do
  @moduledoc """
  Web scraper
  """

  def main() do
    http_client().start()

    root_path = File.cwd!()

    download_urls_from_file(root_path)
    |> Stream.run()
  end

  def download_urls_from_file(root_path) do
    root_path
    |> load_urls()
    |> Stream.map(&download_url(&1, root_path))
  end

  def download_url(url, root_path) do
    file_name = Hash.md5(url, :hex)
    file_path = Path.join(root_path, file_name)

    url
    |> get_url()
    |> get_body()
    |> write_response(file_path)
  end

  def get_url(url) do
    http_client().get!(url)
  end

  def get_body(%HTTPoison.Response{
        status_code: 200,
        body: body
      }) do
    body
  end

  def write_response(response, file_path) do
    File.write!(file_path, response)
  end

  def load_urls(dir_path) do
    input_path = Application.get_env(:onigumo, :input_path)

    Path.join(dir_path, input_path)
    |> File.stream!([:read], :line)
    |> Stream.map(&String.trim_trailing/1)
  end

  defp http_client() do
    Application.get_env(:onigumo, :http_client)
  end

  def create_file_name(url) do
    Base.url_encode64(url, padding: false)
  end
end
