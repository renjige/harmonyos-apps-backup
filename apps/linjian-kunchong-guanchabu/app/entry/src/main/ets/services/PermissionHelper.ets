import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit'
import { PrivacyService } from './PrivacyService'

export class PermissionRequestResult {
  granted: boolean = false
  message: string = ''
}

export class PermissionHelper {
  static async request(context: common.UIAbilityContext, permission: Permissions): Promise<PermissionRequestResult> {
    const result = new PermissionRequestResult()
    if (!PrivacyService.isAccepted()) {
      result.message = '请先同意隐私政策'
      return result
    }
    try {
      const atManager = abilityAccessCtrl.createAtManager()
      const status = await atManager.checkAccessToken(context.applicationInfo.accessTokenId, permission)
      if (status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        result.granted = true
        return result
      }
      const req = await atManager.requestPermissionsFromUser(context, [permission])
      if (req.authResults.length > 0) {
        let granted = false
        for (const code of req.authResults) {
          if (code === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
            granted = true
          }
        }
        result.granted = granted
      }
      if (!result.granted) {
        result.message = '未获得所需权限，可在系统设置中开启'
      }
    } catch {
      result.message = '权限申请失败'
    }
    return result
  }

  static async ensureLocation(context: common.UIAbilityContext): Promise<PermissionRequestResult> {
    const approx = await PermissionHelper.request(context, 'ohos.permission.APPROXIMATELY_LOCATION')
    if (!approx.granted) {
      return approx
    }
    const precise = await PermissionHelper.request(context, 'ohos.permission.LOCATION')
    if (precise.granted) {
      return precise
    }
    return approx
  }

  static async ensureCamera(context: common.UIAbilityContext): Promise<PermissionRequestResult> {
    return PermissionHelper.request(context, 'ohos.permission.CAMERA')
  }
}
