variable routes_to_ilb {
  type        = map(object({
      name         = string
      network_name = string
      next_hop_ilb = string
      priority     = number
      destination  = string
  }))
  description = "List of routes that point to loadBalancingScheme=INTERNAL"
  default     = {}
}
