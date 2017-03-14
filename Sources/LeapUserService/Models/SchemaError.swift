
enum SchemaError: Error {
    case missingField(field: String)
    case wrongType(field: String)
    case badData(field: String)
}
