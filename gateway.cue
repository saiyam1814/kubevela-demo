gateway: {
	alias: ""
	annotations: {}
	attributes: {
		status: {}
		appliesToWorkloads: ["deployments.apps", "statefulsets.apps"]
		podDisruptive: false
	}
	description: "Enable public web traffic for the component, the ingress API matches K8s v1.20+."
	labels: {}
	type: "trait"
}

template: {
	// trait template can have multiple outputs in one trait
	outputs: service: {
		apiVersion: "v1"
		kind:       "Service"
		metadata: name: context.name
		spec: {
			selector: "app.oam.dev/component": context.name
			ports: [
				for k, v in parameter.http {
					port:       v
					targetPort: v
				},
			]
		}
	}
	outputs: ingress: {
		apiVersion: "networking.k8s.io/v1"
		kind:       "Ingress"
		metadata: {
			name: context.name
			annotations: {
				if !parameter.classInSpec {
					"kubernetes.io/ingress.class": parameter.class
				}
				if parameter.gatewayHost != _|_ {
					"ingress.controller/host": parameter.gatewayHost
				}
			}
		}
		spec: {
			if parameter.classInSpec {
				ingressClassName: parameter.class
			}
			if parameter.secretName != _|_ {
				tls: [{
					hosts: [
						parameter.domain,
					]
					secretName: parameter.secretName
				}]
			}
			rules: [{
				if parameter.domain != _|_ {
					host: parameter.domain
				}
				http: paths: [
					for k, v in parameter.http {
						path:     k
						pathType: "ImplementationSpecific"
						backend: service: {
							name: context.name
							port: number: v
						}
					},
				]
			}]
		}
	}
	parameter: {
		// +usage=Specify the domain you want to expose
		domain?: string

		// +usage=Specify the mapping relationship between the http path and the workload port
		http: [string]: int

		// +usage=Specify the class of ingress to use
		class: *"nginx" | string

		// +usage=Set ingress class in '.spec.ingressClassName' instead of 'kubernetes.io/ingress.class' annotation.
		classInSpec: *false | bool

		// +usage=Specify the secret name you want to quote to use tls.
		secretName?: string

		// +usage=Specify the host of the ingress gateway, which is used to generate the endpoints when the host is empty.
		gatewayHost?: string
	}
}

