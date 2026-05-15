class ApiConstants {
  const ApiConstants._();

  static const baseUrl = 'https://hacker-news.firebaseio.com/v0';
  static const topStories = '/topstories.json';
  static String item(int id) => '/item/$id.json';
}
