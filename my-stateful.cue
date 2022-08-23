"my-stateful": {
	alias: ""
	annotations: {}
	attributes: workload: definition: {
		apiVersion: "<change me> apps/v1"
		kind:       "<change me> Deployment"
	}
	description: "My StatefulSet component."
	labels: {}
	type: "component"
}

template: {
	output: {
		apiVersion: "core.oam.dev/v1beta1"
		kind:       "Application"
		metadata: name: "kubevela-saiyam-demo"
		spec: {
			policies: [{
				name: "target-default"
				properties: {
					clusters: ["local"]
					namespace: "default"
				}
				type: "topology"
			}, {
				name: "target-prod"
				properties: {
					clusters: ["local"]
					namespace: "prod"
				}
				type: "topology"
			}, {
				name: "deploy-ha"
				properties: components: [{
					type: "webservice"
					traits: [{
						properties: replicas: 2
						type: "scaler"
					}, {
						properties: domain: "prod.e07cf142-a0a5-4d86-8874-7a273aef053c.k8s.civo.com"
						type: "gateway"
					}]
				}]
				type: "override"
			}]
			components: [{
				name: "kubesimplify"
				properties: {
					image: "saiyam911/kubeworkshop:sha-e9b7f55"
					ports: [{
						expose: true
						port:   8080
					}]
				}
				type: "webservice"
				traits: [{
					properties: replicas: 1
					type: "scaler"
				}, {
					properties: env: PORT: "8080"
					type: "env"
				}, {
					properties: {
						class:  "traefik"
						domain: "demo.e07cf142-a0a5-4d86-8874-7a273aef053c.k8s.civo.com"
						http: "/": 8080
					}
					type: "gateway"
				}]
			}]
			workflow: steps: [{
				name: "deploy2default"
				properties: policies: ["target-default"]
				type: "deploy"
			}, {
				name: "manual-approval"
				type: "suspend"
			}, {
				name: "deploy2prod"
				properties: policies: ["target-prod", "deploy-ha"]
				type: "deploy"
			}]
		}
	}
	outputs: {}
	parameter: {}
}
