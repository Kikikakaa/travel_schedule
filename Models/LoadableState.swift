enum LoadableState<Value> {
    case idle
    case loading
    case loaded(Value)
    case noPermission
    case error(String)
}
