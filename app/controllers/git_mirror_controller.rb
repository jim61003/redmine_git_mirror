
class GitMirrorController < ActionController::Base

  # abstract hook for repo update via remote url
  def fetch
    found = fetch_by_urls(params[:url])
    head found ? 202 : 404
  end

  # process gitlab webhook request
  def gitlab
    event = params[:event_name]
    unless request.post? && event
      head 400
      return
    end

    unless %w[push repository_update].include?(event.to_s)
      head 200
      return
    end

    project = params[:project]
    unless project
      head 422
      return
    end

    urls = []

    [:git_ssh_url, :git_http_url].each do |p|
      url = project[p].to_s

      urls.push(url) if url.length > 0
    end

    if urls.length <= 0
      head 422
      return
    end

    found = fetch_by_urls(urls)
    head found ? 202 : 404
  end

  # process github webhook request
  def github
    event = request.headers["x-github-event"]
    unless request.post? && event
      head 400
      return
    end

    unless %w[push].include?(event.to_s)
      head 200
      return
    end

    payload = params[:payload]

    if payload && request.content_type != 'application/json'
      payload = JSON.parse(payload, :symbolize_names => true)
    else
      payload = params
    end

    unless payload
      head 422
      return
    end

    repository = payload[:repository]
    unless repository
      head 422
      return
    end

    urls = []

    [:ssh_url, :clone_url, :git_url].each do |p|
      url = repository[p].to_s

      urls.push(url) if url.length > 0
    end

    if urls.length <= 0
      head 422
      return
    end

    found = fetch_by_urls(urls)
    head found ? 202 : 404
  end

  private def fetch_by_urls(urls)
    urls_to_search = []

    urls.each do |url|
      begin
        urls_to_search.concat RedmineGitMirror::URL.parse(url).vary
      rescue Exception => _
        urls_to_search.push(url)
      end
    end

    found = false

    atp_log "JDH: URLs to search gitea: #{urls_to_search}"

    # iterate over all urls 
    Repository::GitMirror.active.each do |repository|
      begin
        atp_log "SK: URL to look for gitea: #{repository.url}"
        atp_log "SK: Base URL to look for gitea: #{repository.url.base_url}"
        if urls_to_search.include? repository.url.base_url
          atp_log "SK: URL found: #{repository.url.base_url}"
          found = true
          repository.fetch()
        end
      end

    #Repository::GitMirror.active.where(url: urls_to_search).find_each do |repository|
     # found = true unless found
     # repository.fetch()
    # end

    found
  end
end
