defmodule FileDownloader do
  use Hound.Helpers
  import Hound.RequestUtils

  def download_elixir_docs do
    # 1) Start hound session
    Hound.start_session()

    # 2) Visit the website
    navigate_to("https://elixir-lang.org/docs.html")

    # 3) By using 'Hound.RequestUtils.make_req', enable file downloading
    {:ok, download_path} = File.cwd()
    session_id = Hound.current_session_id()

    make_req(
      :post,
      "session/#{session_id}/chromium/send_command",
      %{
        cmd: "Page.setDownloadBehavior",
        params: %{behavior: "allow", downloadPath: download_path}
      }
    )

    # 4) Find download link and click it to download file
    download_link = {:xpath, "//*[@id='stable']/small/a"}
    download_link |> click()

    # 5) Wait until download process is completed
    wait_download_started(download_path)
    wait_download_completed(download_path)

    # 6) Stop hound session
    Hound.end_session()
  end

  defp wait_download_started(download_path) do
    wait_crdownload(download_path, true)
  end

  defp wait_download_completed(download_path) do
    wait_crdownload(download_path, false)
  end

  defp wait_crdownload(dir, exist?, wait_time \\ 1000) do
    count_crdownload =
      dir
      |> Path.join("*.crdownload")
      |> Path.wildcard()
      |> Enum.count()

    unless((count_crdownload != 0 && exist?) || (count_crdownload == 0 && !exist?)) do
      Process.sleep(wait_time)
      wait_crdownload(dir, exist?, wait_time)
    end
  end
end
