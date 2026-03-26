module MangasHelper
  def status_badge(manga)
    classes = case manga.status
    when "ongoing" then "bg-green-600 text-white"
    when "completed" then "bg-blue-600 text-white"
    when "hiatus" then "bg-yellow-500 text-white"
    when "canceled" then "bg-red-600 text-white"
    end
  content_tag :span, manga.status.humanize,
      class: "inline-block px-3 py-1.5 rounded text-xs font-bold uppercase tracking-wide #{classes}"
  end
end
