import { media } from '@kit.MediaKit'
import { audio } from '@kit.AudioKit'
import { common } from '@kit.AbilityKit'
import { vibrator } from '@kit.SensorServiceKit'

/** 答题轻提示音 + 短振动（不申请麦克风权限） */
export class MathFeedbackService {
  private static pool: media.SoundPool | null = null
  private static correctId: number = -1
  private static gentleId: number = -1
  private static tapId: number = -1
  private static ready: boolean = false
  private static context: common.UIAbilityContext | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    MathFeedbackService.context = context
    try {
      const info: audio.AudioRendererInfo = {
        usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
        rendererFlags: 0
      }
      MathFeedbackService.pool = await media.createSoundPool(3, info)
      MathFeedbackService.correctId = await MathFeedbackService.loadRaw('correct.wav')
      MathFeedbackService.gentleId = await MathFeedbackService.loadRaw('gentle.wav')
      MathFeedbackService.tapId = await MathFeedbackService.loadRaw('tap.wav')
      MathFeedbackService.ready = true
    } catch {
      MathFeedbackService.ready = false
    }
  }

  private static async loadRaw(name: string): Promise<number> {
    if (MathFeedbackService.pool === null || MathFeedbackService.context === null) {
      return -1
    }
    const fd = await MathFeedbackService.context.resourceManager.getRawFd(name)
    return await MathFeedbackService.pool.load(fd.fd, fd.offset, fd.length)
  }

  static playCorrect(sound: boolean): void {
    if (!sound) {
      return
    }
    MathFeedbackService.playId(MathFeedbackService.correctId)
    MathFeedbackService.vibrate(40)
  }

  static playGentle(sound: boolean): void {
    if (!sound) {
      return
    }
    MathFeedbackService.playId(MathFeedbackService.gentleId)
    MathFeedbackService.vibrate(25)
  }

  static playTap(sound: boolean): void {
    if (!sound) {
      return
    }
    MathFeedbackService.playId(MathFeedbackService.tapId)
  }

  private static playId(id: number): void {
    if (!MathFeedbackService.ready || id < 0 || MathFeedbackService.pool === null) {
      return
    }
    try {
      MathFeedbackService.pool.play(id, {
        loop: 0,
        rate: 1.0,
        leftVolume: 0.65,
        rightVolume: 0.65,
        priority: 0
      })
    } catch {
    }
  }

  private static vibrate(ms: number): void {
    try {
      vibrator.startVibration({ type: 'time', duration: ms }, { id: 0, usage: 'touch' })
    } catch {
    }
  }
}
