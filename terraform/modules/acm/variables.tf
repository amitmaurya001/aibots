variable "cert" {
  type = object({
    main = map(string)
    sans = list(map(string))
  })
}

variable "cert_name" {
  type = string
}
