import { geoLocationManager } from '@kit.LocationKit'

class InsectLocationRequest {
  priority: geoLocationManager.LocationRequestPriority =
    geoLocationManager.LocationRequestPriority.FIRST_FIX
  scenario: geoLocationManager.LocationRequestScenario =
    geoLocationManager.LocationRequestScenario.UNSET
  maxAccuracy: number = 0
}

export class LocationResult {
  label: string = ''
  latitude: number = 0
  longitude: number = 0
}

export class LocationHelper {
  static async current(): Promise<LocationResult> {
    const out = new LocationResult()
    try {
      const req = new InsectLocationRequest()
      const loc: geoLocationManager.Location = await geoLocationManager.getCurrentLocation(req)
      out.latitude = loc.latitude
      out.longitude = loc.longitude
      out.label = `${loc.latitude.toFixed(4)}, ${loc.longitude.toFixed(4)}`
    } catch {
      out.label = ''
    }
    return out
  }
}
