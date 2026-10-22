class Api::V1::SearchController < Api::V1::ApiController
  api! "검색 결과를 전달한다."
  param :q, String, desc: "검색 키워드", required: true
  param :limit, Integer, desc: "검색 결과의 최대 개수, 기본값은 5", required: false
  def index
    q = params[:q]
    limit = params[:limit] || 6
    @articles = search_with_total(Article, q).per(limit).records
    comments = search_with_total(Comment, q).per(limit).records
    @comments_total = comments.total
    @comments = comments.includes(:article)
    @profiles = search_with_total(Profile, q).per(limit).records
    @tags = search_with_total(Tag, q).per(limit).records
  end

  api! "글 검색 결과를 전달한다."
  param :q, String, desc: "검색 키워드", required: true
  param :page, Integer, desc: "검색 결과 페이지의 번호, 기본값은 1", required: false
  param :limit, Integer, desc: "검색 결과의 최대 개수, 기본값은 10", required: false
  def article
    q = params[:q]
    page = params[:page] || 1
    limit = params[:limit] || 10
    @articles = search_with_total(Article, q).page(page).per(limit).records
  end

  api! "댓글 검색 결과를 전달한다."
  param :q, String, desc: "검색 키워드", required: true
  param :page, Integer, desc: "검색 결과 페이지의 번호, 기본값은 1", required: false
  param :limit, Integer, desc: "검색 결과의 최대 개수, 기본값은 10", required: false
  def comment
    q = params[:q]
    page = params[:page] || 1
    limit = params[:limit] || 10
    comments = search_with_total(Comment, q).page(page).per(limit).records
    @comments_total = comments.total
    @comments = comments.includes(:article)
  end

  api! "프로필 검색 결과를 전달한다."
  param :q, String, desc: "검색 키워드", required: true
  param :page, Integer, desc: "검색 결과 페이지의 번호, 기본값은 1", required: false
  param :limit, Integer, desc: "검색 결과의 최대 개수, 기본값은 10", required: false
  def profile
    q = params[:q]
    page = params[:page] || 1
    limit = params[:limit] || 10
    @profiles = search_with_total(Profile, q).page(page).per(limit).records
  end

  api! "태그 검색 결과를 전달한다."
  param :q, String, desc: "검색 키워드", required: true
  param :page, Integer, desc: "검색 결과 페이지의 번호, 기본값은 1", required: false
  param :limit, Integer, desc: "검색 결과의 최대 개수, 기본값은 10", required: false
  def tag
    q = params[:q]
    page = params[:page] || 1
    limit = params[:limit] || 10
    @tags = search_with_total(Tag, q).page(page).per(limit).records
  end
end

  private

  def search_with_total(model, query)
    model.search({query: {query_string: {query: query}}, track_total_hits: true})
  end
