// Create a request variable and assign a new XMLHttpRequest object to it.
class TMDB {
	constructor() {
		this.find = function(movie) {
			var request = new XMLHttpRequest()
			var urlStr = 'https://api.themoviedb.org/3/search/movie?api_key=305ae312343163e9a891637b00d624c9&language=en-US&query=' + encodeURI(movie) + '&page=1&include_adult=false'
			request.open('GET', urlStr, true)
			return request;
		}
		this.person = function(person) {
			var request = new XMLHttpRequest()
			var urlStr = 'https://api.themoviedb.org/3/search/person?api_key=305ae312343163e9a891637b00d624c9&language=en-US&query=' + encodeURI(person) + '&page=1&include_adult=false'
			request.open('GET', urlStr, true)
			return request;
		}
	}
}

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
var movie = document.getElementById('Populate Field')
movie.onclick = function() {
	var request = new XMLHttpRequest()
	// Open a new connection, using the GET request on the URL endpoint
	request.open('GET', 'https://api.themoviedb.org/3/search/movie?api_key=305ae312343163e9a891637b00d624c9&language=en-US&query=Avengers%3A%20Endgame&page=1&include_adult=false', true)

	request.onload = function() {
	  	// Begin accessing JSON data here
		var data = JSON.parse(this.response)
		console.log(data);
	}

	// Send request
	request.send()	
}

