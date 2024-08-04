variable "ports" {
  type = map(list(number))
  default = {
    inbound = [ 22, 80, 443, ]
    outbound = [ 22, 80, 443, ]
  }
}