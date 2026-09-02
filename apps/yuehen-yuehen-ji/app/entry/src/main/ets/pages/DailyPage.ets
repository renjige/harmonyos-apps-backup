import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { EmotionCatalog } from '../models/EmotionCatalog'
import { EmotionDef, MoodRecord } from '../models/MoodModels'
import { DateHelper } from '../services/DateHelper'
import { MoonPhaseHelper } from '../services/MoonPhaseHelper'
import { MoodStore } from '../services/MoodStore'
import { PhotoPickService } from '../services/PhotoPickService'

@Component
export struct DailyPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop reloadToken: number = 0
  @State dateKey: string = DateHelper.todayKey()
  @State selected: string[] = []
  @State diary: string = ''
  @State score: number = 5
  @State imagePath: string = ''
  @State recordId: string = ''
  @State saving: boolean = false
  @State toastText: string = ''
  @State refreshSeen: number = 0
  private uiContext: common.UIAbilityContext | null = null
  private emotions: EmotionDef[] = EmotionCatalog.all()

  aboutToAppear(): void {
    void this.loadToday()
  }

  private onReload(): void {
    if (this.reloadToken !== this.refreshSeen) {
      this.refreshSeen = this.reloadToken
      void this.loadToday()
    }
  }

  private async loadToday(): Promise<void> {
    this.dateKey = DateHelper.todayKey()
    const existing = await MoodStore.findByDateKey(this.dateKey)
    if (existing !== undefined) {
      this.recordId = existing.id
      this.selected = existing.emotions.slice()
      this.diary = existing.diary
      this.score = existing.score
      this.imagePath = existing.imagePath
      return
    }
    this.recordId = ''
    this.selected = []
    this.diary = ''
    this.score = 5
    this.imagePath = ''
  }

  private toggleEmotion(id: string): void {
    const next: string[] = []
    let found = false
    for (const e of this.selected) {
      if (e === id) {
        found = true
      } else {
        next.push(e)
      }
    }
    if (!found) {
      if (next.length < 3) {
        next.push(id)
      } else {
        this.showToast('最多选择 3 种主导情绪')
        return
      }
    }
    this.selected = next
  }

  private isSelected(id: string): boolean {
    for (const e of this.selected) {
      if (e === id) {
        return true
      }
    }
    return false
  }

  private async saveRecord(): Promise<void> {
    if (this.selected.length === 0 && this.diary.trim().length === 0 && this.imagePath.length === 0) {
      this.showToast('请至少选择一种情绪或写一句话')
      return
    }
    this.saving = true
    let record: MoodRecord
    if (this.recordId.length > 0) {
      const found = await MoodStore.findById(this.recordId)
      record = found ?? MoodRecord.createNew(this.dateKey)
    } else {
      record = MoodRecord.createNew(this.dateKey)
      this.recordId = record.id
    }
    record.dateKey = this.dateKey
    record.emotions = this.selected.slice()
    record.diary = this.diary.slice(0, 200)
    record.score = this.score
    record.imagePath = this.imagePath
    await MoodStore.saveRecord(record)
    this.saving = false
    this.showToast('今日月痕已保存')
  }

  private async pickImage(): Promise<void> {
    if (this.uiContext === null) {
      return
    }
    const uri = await PhotoPickService.pickOneImage(this.uiContext)
    if (uri.length > 0) {
      this.imagePath = uri
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.hero_moonlight_bg'))
              .width('100%')
              .height(120)
              .objectFit(ImageFit.Cover)
              .borderRadius({ bottomLeft: Theme.radius.lg, bottomRight: Theme.radius.lg })
            Column({ space: 4 }) {
              Row({ space: Theme.space.s2 }) {
                Text(MoonPhaseHelper.phaseSymbol())
                  .fontSize(22)
                Text(MoonPhaseHelper.phaseLabel())
                  .fontSize(Theme.type.caption)
                  .fontColor('#FFFFFF')
              }
              Text(DateHelper.displayDate(this.dateKey))
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text(DateHelper.displayWeekday(this.dateKey))
                .fontSize(Theme.type.bodyS)
                .fontColor('#F5F0EB')
            }
            .padding(Theme.space.s5)
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,26,46,0)', 0], ['rgba(26,26,46,0.72)', 1]]
            })
            .width('100%')
            .height(120)
            .justifyContent(FlexAlign.End)
          }
          .width('100%')

          Column({ space: Theme.space.s3 }) {
            Text('今日情绪（可选 1～3 种）')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
              ForEach(this.emotions, (e: EmotionDef) => {
                Column({ space: 4 }) {
                  Text(e.emoji)
                    .fontSize(18)
                  Text(e.label)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.isSelected(e.id) ? Theme.colors().brandDeep : Theme.colors().textSecondary)
                }
                .width(72)
                .height(72)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(this.isSelected(e.id) ? e.color : Theme.colors().surfaceSubtle)
                .borderRadius(36)
                .border({
                  width: this.isSelected(e.id) ? 2 : 0,
                  color: Theme.colors().brandPrimary
                })
                .margin({ right: 10, bottom: 10 })
                .onClick((): void => { this.toggleEmotion(e.id) })
              }, (e: EmotionDef) => e.id)
            }
            .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Column({ space: Theme.space.s2 }) {
            Text('一句话日记（200 字内）')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            TextArea({ text: this.diary, placeholder: '记录今日最值得铭记的瞬间…' })
              .height(100)
              .fontSize(Theme.type.body)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string) => { this.diary = v.slice(0, 200) })
            Text(`${this.diary.length}/200`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
              .textAlign(TextAlign.End)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          if (this.imagePath.length > 0) {
            Stack({ alignContent: Alignment.TopEnd }) {
              Image(this.imagePath)
                .width('100%')
                .height(120)
                .borderRadius(Theme.radius.md)
                .objectFit(ImageFit.Cover)
              Row() {
                AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textOnInverse })
              }
              .padding(8)
              .backgroundColor('rgba(0,0,0,0.35)')
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.imagePath = '' })
            }
            .width('100%')
          }

          Column({ space: Theme.space.s3 }) {
            Row() {
              Text('情绪能量')
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Blank()
              Text(`${this.score}`)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            }
            .width('100%')
            Slider({
              value: this.score,
              min: 1,
              max: 10,
              step: 1,
              style: SliderStyle.OutSet
            })
              .blockColor(Theme.colors().brandPrimary)
              .trackColor(Theme.colors().surfaceSubtle)
              .selectedColor(Theme.colors().brandAccent)
              .onChange((v: number) => { this.score = Math.round(v) })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Row({ space: Theme.space.s3 }) {
            AppButton({
              label: '添加配图',
              variant: 'secondary',
              onTap: (): void => { void this.pickImage() }
            }).layoutWeight(1)
            AppButton({
              label: this.saving ? '保存中…' : '保存今日',
              variant: 'primary',
              onTap: (): void => { void this.saveRecord() }
            }).layoutWeight(1)
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '15%', y: 48 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .onAppear((): void => {
      this.onReload()
      const host = this.getUIContext().getHostContext()
      if (host !== undefined) {
        this.uiContext = host as common.UIAbilityContext
      }
    })
  }
}
