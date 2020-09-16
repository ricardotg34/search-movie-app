import 'package:flutter/material.dart';
import 'package:peliculas/src/models/movie_model.dart';
import 'package:peliculas/src/providers/movies_provider.dart';

class DataSearch extends SearchDelegate {

  final moviesProvider = MoviesProvider();

  @override
  List<Widget> buildActions(BuildContext context) {
      return [
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: (){
            query = '';
          }
        )
      ];
    }

    @override
    Widget buildLeading(BuildContext context) {
      // Icono a la izquierda del app bar
      return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: (){
          close(context, null);
        }
      );
    }

    @override
    Widget buildResults(BuildContext context) {
      // Crea los resultados a mostrar
      return Container();
    }

    @override
    Widget buildSuggestions(BuildContext context) {
      // Sugerencias que aparecen cuando el usuario escribe.
      if(query.isEmpty) {
        return Container();
      }
      return FutureBuilder(
        future: moviesProvider.searchMovie(query),
        builder: (BuildContext context, AsyncSnapshot<List<Movie>> snapshot) {
          if (snapshot.hasData) {
            final movies = snapshot.data;
            return ListView(
              children: movies.map((movie) => ListTile(
                leading: FadeInImage(
                  placeholder: AssetImage('assets/img/no-image.jpg'),
                  image: NetworkImage(movie.getPosterImg()),
                  width: 50,
                  fit: BoxFit.contain,
                ),
                title: Text(movie.title),
                subtitle: Text(movie.originalTitle),
                onTap: (){
                  close(context, null);
                  movie.uniqueId = '';
                  Navigator.pushNamed(context, 'detalle', arguments: movie);
                },
              )).toList(),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );
    }
}