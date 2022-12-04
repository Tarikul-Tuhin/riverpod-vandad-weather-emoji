import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

enum City {
  Dhaka,
  Chittagong,
  Barishal,
}

typedef WeatherEmoji = String;

const confusedEmoji = '🤔';

Future<WeatherEmoji> getWeather(City city) {
  return Future.delayed(const Duration(seconds: 1), () async {
    return {
      City.Barishal: '🌧️',
      City.Dhaka: '⚡',
      City.Chittagong: '🌞',
    }[city]!; // [city] = [City.Dhaka]
  });
}

// read and write
final currentCityProvider = StateProvider<City?>(
  (ref) => null,
);
// read
final weatherProvider = FutureProvider<WeatherEmoji>((ref) {
  final city = ref.watch(currentCityProvider);
  if (city != null) {
    return getWeather(city);
  } else {
    return confusedEmoji;
  }
});

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeather = ref.watch(weatherProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
      ),
      body: Column(
        children: [
          currentWeather.when(
              data: (data) => Text(
                    data,
                    style: const TextStyle(fontSize: 50),
                  ),
              error: ((error, stackTrace) => const Text('Error')),
              loading: () => const CircularProgressIndicator()),
          Expanded(
            child: ListView.builder(
              itemCount: City.values.length,
              itemBuilder: ((context, index) {
                final city = City.values[index];
                final isSelected = city == ref.watch(currentCityProvider);
                return ListTile(
                  title: Text(
                    city.toString(),
                  ),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  onTap: () {
                    ref.read(currentCityProvider.notifier).state = city;
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
