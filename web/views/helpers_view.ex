defmodule SecureMessenger.ViewHelper do
  def current_user(conn), do: Guardian.Plug.current_resource(conn)
  def logged_in?(conn), do: Guardian.Plug.authenticated?(conn)
  def gravatar_img(conn, size), do: current_user(conn).gravatar_url <> "?s=#{size}"


  def convert_time(conn, created_at) do
    timezone = Timex.Timezone.get(current_user(conn).timezone, created_at)
    current_time = Timex.Timezone.convert(created_at, timezone)
    Timex.format!(current_time, "%l:%M%P", :strftime)
  end

  def convert_text(body) do
    regex = ~r/((?:(http|https|Http|Https|rtsp|Rtsp):\/\/(?:(?:[a-zA-Z0-9\$\-\_\.\+\!\*\'\(\)\,\;\?\&\=]|(?:\%[a-fA-F0-9]{2})){1,64}(?:\:(?:[a-zA-Z0-9\$\-\_\.\+\!\*\'\(\)\,\;\?\&\=]|(?:\%[a-fA-F0-9]{2})){1,25})?\@)?)?((?:(?:[a-zA-Z0-9][a-zA-Z0-9\-]{0,64}\.)+(?:(?:aero|arpa|asia|a[cdefgilmnoqrstuwxz])|(?:biz|b[abdefghijmnorstvwyz])|(?:cat|com|coop|c[acdfghiklmnoruvxyz])|d[ejkmoz]|(?:edu|e[cegrstu])|f[ijkmor]|(?:gov|g[abdefghilmnpqrstuwy])|h[kmnrtu]|(?:info|int|i[delmnoqrst])|(?:jobs|j[emop])|k[eghimnrwyz]|l[abcikrstuvy]|(?:mil|mobi|museum|m[acdghklmnopqrstuvwxyz])|(?:name|net|n[acefgilopruz])|(?:org|om)|(?:pro|p[aefghklmnrstwy])|qa|r[eouw]|s[abcdeghijklmnortuvyz]|(?:tel|travel|t[cdfghjklmnoprtvwz])|u[agkmsyz]|v[aceginu]|w[fs]|y[etu]|z[amw]))|(?:(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9])\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9]|0)\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9]|0)\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[0-9])))(?:\:\d{1,5})?)(\/(?:(?:[a-zA-Z0-9\;\/\?\:\@\&\=\#\~\-\.\+\!\*\'\(\)\,\_])|(?:\%[a-fA-F0-9]{2}))*)?(?:\b|$)/
    results = Regex.scan(regex, body)
    |> Enum.map(&(List.first(&1)))
    |> (&(recursive_link_convert(body, &1))).()
  end

  def recursive_link_convert(body, targets) do
    target = List.first(targets)
    if target do
      altered_target = if String.starts_with?(target, "www") do
        "http://#{target}"
      else
        target
      end
      if String.ends_with?(target, [".gif", ".jpg", ".png"]) do
        altered_body = String.replace(body, target, "<div class='image-added'>added an image:</div><div class='gif'><img src=#{altered_target} /></div>")
      else
        altered_body = String.replace(body, target, "<a href=#{altered_target} target='_blank'>#{target}</a>")
      end
      altered_targets = List.delete_at(targets, 0)
      recursive_link_convert(altered_body, altered_targets)
    else
      body
    end
  end

end
