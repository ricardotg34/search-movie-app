import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:peliculas/src/models/actor_model.dart';
import 'package:peliculas/src/models/movie_model.dart';

class MoviesProvider {
  String _apikey = '30a90ccbb0af0350f28445768c87e2c9';
  String _url ='api.themoviedb.org';
  String _language = 'es-ES';
  int _popularPage = 0; //define qué pagina se va a pedir en el request
  bool _loading = false;
  // Va  tener la lista de peliculas populares, que crecerá dinamicamente
  List<Movie> _popular = new List();
  // Se crea un stream de tipo broadcast, para que pueda ser escuchado desde diferentes partes de la app.
  // Este streamva a manejar una lista de películas.
  final _popularStreamController = StreamController<List<Movie>>.broadcast();

  // Función que agrega una nueva película al streamcontroller
  Function(List<Movie>) get popularSink => _popularStreamController.sink.add;
  // Función que se va a utilizar para escuchar cuando se agregue una nueva película.
  Stream<List<Movie>> get popularStream => _popularStreamController.stream;

  void disposeStream (){
    _popularStreamController?.close();
  }

  Future<List<Movie>> _processResult(Uri url) async {
    final res = await http.get(url);
    final decodedData = json.decode(res.body);
    final peliculas = new Movies.fromJsonList(decodedData['results']);
    return peliculas.items;
  }

  Future<List<Movie>> getOnTheaters() async {
    final url = Uri.https(_url, '3/movie/now_playing', {
      'api_key': _apikey,
      'language': _language
    });
    return await _processResult(url);
  }

  Future<List<Movie>> getPopular() async {
    // Sirve para no renderizar inecesariamente paginas de peliculas populares
    if ( _loading ) return [];
    _loading = true;

    _popularPage++;
    final url = Uri.https(_url, '3/movie/popular', {
      'api_key': _apikey,
      'language': _language,
      'page': _popularPage.toString()
    });
    final resp = await _processResult(url);

    _popular.addAll(resp);
    popularSink(_popular);
    _loading = false;
    return resp;
  }

  Future<List<Actor>> getCast(String movieId) async {
    final url = Uri.https(_url, '3/movie/$movieId/credits', {
      'api_key': _apikey,
      'language': _language
    });
    final resp = await http.get(url);
    final decodedData = json.decode(resp.body);
    final cast = new Cast.fromJsonList(decodedData['cast']);

    return cast.actors;
  }

  Future<List<Movie>> searchMovie(String query) async {
    final url = Uri.https(_url, '3/search/movie', {
      'api_key': _apikey,
      'language': _language,
      'query': query
    });
    return await _processResult(url);
  }
}