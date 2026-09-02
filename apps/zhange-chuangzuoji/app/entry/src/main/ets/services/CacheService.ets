import { fileIo } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'

export class CacheService {
  static clearExportCache(context: common.UIAbilityContext): number {
    const dir = `${context.filesDir}/export`
    let removed = 0
    try {
      const names = fileIo.listFileSync(dir)
      for (const name of names) {
        try {
          fileIo.unlinkSync(`${dir}/${name}`)
          removed++
        } catch {
          // skip
        }
      }
    } catch {
      return 0
    }
    return removed
  }
}
