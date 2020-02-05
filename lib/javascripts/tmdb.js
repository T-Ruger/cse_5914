class TMDB {
	find(movie) {
		console.log("hello")
		var request = new XMLHttpRequest()
		var urlStr = 'https://api.themoviedb.org/3/search/movie?api_key=305ae312343163e9a891637b00d624c9&language=en-US&query=' + encodeURI(movie) + '&page=1&include_adult=false'
		request.open('GET', urlStr, true)
		return request
	}
	cast(person) {
		var request = new XMLHttpRequest()
		var urlStr = 'https://api.themoviedb.org/3/search/person?api_key=305ae312343163e9a891637b00d624c9&language=en-US&query=' + encodeURI(person) + '&page=1&include_adult=false'
		request.open('GET', urlStr, true)
		return request
	}

	popular() {
		var request = new XMLHttpRequest()
		var urlStr = 'https://api.themoviedb.org/3/movie/popular?api_key=305ae312343163e9a891637b00d624c9&language=en-US&page=1'
		request.open('GET', urlStr, true)
		return request;
	}
	top_rated() {
		var request = new XMLHttpRequest()
		var urlStr = 'https://api.themoviedb.org/3/movie/top_rated?api_key=305ae312343163e9a891637b00d624c9&language=en-US&page=1'
		request.open('GET', urlStr, true)
		return request;
	}

	similar(movie_id) {
		var request = new XMLHttpRequest()
		var urlStr = 'https://api.themoviedb.org/3/movie/' + movie_id + '/similar?api_key=305ae312343163e9a891637b00d624c9&language=en-US&page=1'
		request.open('GET', urlStr, true)
		return request;
	}

}
function search() {
	var database = new TMDB()
	var request = database.cast(document.getElementById("search").value)
	request.onload = function() {
		console.log(JSON.parse(request.response).results)
	}
	request.send()

}
document.getElementById("submit").addEventListener("click", search)

var genre = new Map()
genre.set("Action", 28)
genre.set("Adventure", 12)
genre.set("Animation", 16)
genre.set("Comedy", 35)
genre.set("Crime", 35)
genre.set("Documentary", 99)
genre.set("Drama", 18)
genre.set("Family", 10751)
genre.set("Fantasy", 14)
genre.set("History", 36)
genre.set("Horror", 27)
genre.set("Music", 10402)
genre.set("Mystery", 9648)
genre.set("Romance", 10749)
genre.set("Science Fiction", 878)
genre.set("TV Movie", 10770)
genre.set("Thriller", 53)
genre.set("War", 10752)
genre.set("Western", 37)

