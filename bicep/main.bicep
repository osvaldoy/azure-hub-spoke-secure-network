targetScope = 'resourceGroup'

param location string = resourceGroup().location
@allowed([
  'dev'
  'test'
  'prod'
])
param env string = 'dev'
param workloadName string = 'network'

param hubAddressPrefix string = '10.0.0.0/16'
param spokeAppAddressPrefix string = '10.10.0.0/16'
param spokeDataAddressPrefix string = '10.20.0.0/16'

param hubSubnetFwPrefix string = '10.0.1.0/24' // placeholder (no firewall yet)
param hubSubnetMgmtPrefix string = '10.0.2.0/24'

param spokeAppSubnetPrefix string = '10.10.1.0/24'
param spokeDataSubnetPrefix string = '10.20.1.0/24'

param tags object = {
  workload: workloadName
  environment: env
  managedBy: 'bicep'
}

var namePrefix = toLower('${workloadName}-${env}')

module hub 'modules/hub.bicep' = {
  name: 'hub-${env}'
  params: {
    location: location
    tags: tags
    vnetName: '${namePrefix}-hub-vnet'
    addressPrefix: hubAddressPrefix
    subnetMgmtPrefix: hubSubnetMgmtPrefix
    subnetFwPrefix: hubSubnetFwPrefix
  }
}

module spokeApp 'modules/spoke.bicep' = {
  name: 'spoke-app-${env}'
  params: {
    location: location
    tags: tags
    vnetName: '${namePrefix}-spoke-app-vnet'
    addressPrefix: spokeAppAddressPrefix
    subnetPrefix: spokeAppSubnetPrefix
    nsgName: '${namePrefix}-spoke-app-nsg'
  }
}

module spokeData 'modules/spoke.bicep' = {
  name: 'spoke-data-${env}'
  params: {
    location: location
    tags: tags
    vnetName: '${namePrefix}-spoke-data-vnet'
    addressPrefix: spokeDataAddressPrefix
    subnetPrefix: spokeDataSubnetPrefix
    nsgName: '${namePrefix}-spoke-data-nsg'
  }
}

// Peering hub <-> spokes
module peerHubToApp 'modules/peering.bicep' = {
  name: 'peer-hub-to-app-${env}'
  params: {
    peeringName: 'peer-hub-to-app'
    sourceVnetName: '${namePrefix}-hub-vnet'
    remoteVnetId: spokeApp.outputs.vnetId
  }
}

module peerAppToHub 'modules/peering.bicep' = {
  name: 'peer-app-to-hub-${env}'
  params: {
    peeringName: 'peer-app-to-hub'
    sourceVnetName: '${namePrefix}-spoke-app-vnet'
    remoteVnetId: hub.outputs.vnetId
  }
}

module peerHubToData 'modules/peering.bicep' = {
  name: 'peer-hub-to-data-${env}'
  params: {
    peeringName: 'peer-hub-to-data'
    sourceVnetName: '${namePrefix}-hub-vnet'
    remoteVnetId: spokeData.outputs.vnetId
  }
}

module peerDataToHub 'modules/peering.bicep' = {
  name: 'peer-data-to-hub-${env}'
  params: {
    peeringName: 'peer-data-to-hub'
    sourceVnetName: '${namePrefix}-spoke-app-vnet'
    remoteVnetId: hub.outputs.vnetId
  }
}

output hubVnetId string = hub.outputs.vnetId
output spokeAppVnetId string = spokeApp.outputs.vnetId
output spokeDataVnetId string = spokeData.outputs.vnetId
