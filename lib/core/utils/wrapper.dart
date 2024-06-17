class Wrapper<D> {
  D? content;

  bool get isEmpty => content == null;

  bool get isNotEmpty => content != null;
}
