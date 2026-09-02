import { geoLocationManager } from '@kit.LocationKit'

class SenyeLocationRequest {
  priority: geoLocationManager.LocationRequestPriority =
    geoLocationManager.LocationRequestPriority.FIRST_FIX
  scenario: geoLocationManager.LocationRequestScenario =
    geoLocationManager.LocationRequestScenario.UNSET
  maxAccuracy: number = 0
}

export class LocationHelper {
  static async currentLabel(): Promise<string> {
    try {
      const req = new SenyeLocationRequest()
      const loc: geoLocationManager.Location = await geoLocationManager.getCurrentLocation(req)
      return `${loc.latitude.toFixed(4)}, ${loc.longitude.toFixed(4)}`
    } catch {
      return ''
    }
  }
}
