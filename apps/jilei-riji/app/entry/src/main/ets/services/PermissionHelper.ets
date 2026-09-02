import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
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
      if (req.authResults.length > 0 && req.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        result.granted = true
      } else {
        result.message = '未获得权限，可在系统设置中开启'
      }
    } catch (err) {
      const e = err as BusinessError
      result.message = e.message ?? '权限申请失败'
    }
    return result
  }

  static async ensureMediaRead(context: common.UIAbilityContext): Promise<PermissionRequestResult> {
    return PermissionHelper.request(context, 'ohos.permission.READ_IMAGEVIDEO')
  }
}
