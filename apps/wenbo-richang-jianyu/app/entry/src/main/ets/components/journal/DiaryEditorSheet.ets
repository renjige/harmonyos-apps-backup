import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { AppIcon } from '../design-system/AppIcon'
import { AlbumPhotoTile } from './AlbumPhotoGrid'
import { CreateDiaryRequest, JournalItem, UpdateDiaryRequest } from '../../models/JournalModels'
import { LifeTag } from '../../models/LifeHubModels'
import { LifeHubStore } from '../../services/LifeHubStore'
import { JournalBizService } from '../../services/JournalBizService'
import { JournalCatalog, JournalChoice } from '../../services/JournalCatalog'
import { PhotoPickService } from '../../services/PhotoPickService'
import { AuthService } from '../../services/AuthService'
import { common } from '@kit.AbilityKit'

@Component
export struct DiaryEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  onClose: () => void = () => {}
  onSaved: (item: JournalItem) => void = (item: JournalItem) => {
    if (item.id.length === 0) {
      return
    }
  }
  onRequireAuth: () => void = () => {}
  @State formTitle: string = ''
  @State formBody: string = ''
  @State formDate: string = ''
  @State formMood: string = ''
  @State formScene: string = ''
  @State formCoverKey: string = ''
  @State extraTags: string[] = []
  @State lifeTags: LifeTag[] = []
  @State formError: string = ''
  @State submitting: boolean = false
  @State picking: boolean = false
  @State pickHint: string = ''
  @State promptText: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  private moods: JournalChoice[] = JournalCatalog.moods()
  private scenes: JournalChoice[] = JournalCatalog.scenes()

  aboutToAppear(): void {
    this.formDate = DiaryEditorSheet.todayIso()
    const prefill = AppStorage.get<string>('journalPrefillDate')
    if (this.editId.length === 0 && prefill !== undefined && prefill !== null && prefill.length >= 10) {
      this.formDate = prefill
      AppStorage.setOrCreate('journalPrefillDate', '')
    }
    this.promptText = JournalCatalog.promptForDate(this.formDate)
    if (this.editId.length === 0) {
      this.applyScenarioPrefill()
    }
    void this.loadLifeTags()
    if (this.editId.length > 0) {
      void this.prefill()
    }
  }

  private async loadLifeTags(): Promise<void> {
    this.lifeTags = await LifeHubStore.loadTags()
  }

  private applyScenarioPrefill(): void {
    const preScene = AppStorage.get<string>('journalPrefillScene')
    if (preScene !== undefined && preScene !== null && preScene.length > 0) {
      this.formScene = preScene
      this.formCoverKey = JournalCatalog.coverForScene(preScene)
      AppStorage.setOrCreate('journalPrefillScene', '')
    }
    const preMood = AppStorage.get<string>('journalPrefillMood')
    if (preMood !== undefined && preMood !== null && preMood.length > 0) {
      this.formMood = preMood
      AppStorage.setOrCreate('journalPrefillMood', '')
    }
    const preTitle = AppStorage.get<string>('journalPrefillTitle')
    if (preTitle !== undefined && preTitle !== null && preTitle.length > 0) {
      this.formTitle = preTitle
      AppStorage.setOrCreate('journalPrefillTitle', '')
    }
    const preBody = AppStorage.get<string>('journalPrefillBody')
    if (preBody !== undefined && preBody !== null && preBody.length > 0) {
      this.formBody = preBody
      AppStorage.setOrCreate('journalPrefillBody', '')
    }
    const preTag = AppStorage.get<string>('journalPrefillTag')
    if (preTag !== undefined && preTag !== null && preTag.length > 0) {
      let found = false
      for (const t of this.extraTags) {
        if (t === preTag) {
          found = true
        }
      }
      if (!found) {
        const next: string[] = []
        next.push(preTag)
        for (const t of this.extraTags) {
          next.push(t)
        }
        this.extraTags = next
      }
      AppStorage.setOrCreate('journalPrefillTag', '')
    }
  }

  private static todayIso(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${mm}-${dd}`
  }

  private async prefill(): Promise<void> {
    const item = await JournalBizService.findDiary(this.editId)
    if (item === undefined) {
      return
    }
    this.formTitle = item.title
    this.formBody = item.body
    this.formDate = item.recordDate.length > 0 ? item.recordDate : DiaryEditorSheet.todayIso()
    this.formMood = item.kind
    this.formScene = item.category
    this.formCoverKey = item.coverKey
    this.promptText = JournalCatalog.promptForDate(this.formDate)
    const extras: string[] = []
    const moodLabel = JournalCatalog.moodLabel(item.kind)
    const sceneLabel = JournalCatalog.sceneLabel(item.category)
    for (const t of item.tags) {
      if (t !== moodLabel && t !== sceneLabel) {
        extras.push(t)
      }
    }
    this.extraTags = extras
  }

  private async pickPhoto(): Promise<void> {
    if (this.picking) {
      return
    }
    this.picking = true
    this.pickHint = ''
    const ctx = getContext(this) as common.UIAbilityContext
    const key = await PhotoPickService.pickMoodPhoto(ctx)
    this.picking = false
    if (key.length > 0) {
      this.formCoverKey = key
      this.pickHint = '已选择相册图片'
    } else {
      this.pickHint = '未选择图片'
    }
  }

  private buildTags(): string[] {
    const tags: string[] = []
    const mood = JournalCatalog.moodLabel(this.formMood)
    const scene = JournalCatalog.sceneLabel(this.formScene)
    if (mood.length > 0) {
      tags.push(mood)
    }
    if (scene.length > 0) {
      tags.push(scene)
    }
    for (const t of this.extraTags) {
      tags.push(t)
    }
    return tags
  }

  private toggleExtra(name: string): void {
    const next: string[] = []
    let found = false
    for (const t of this.extraTags) {
      if (t === name) {
        found = true
      } else {
        next.push(t)
      }
    }
    if (!found) {
      next.push(name)
    }
    this.extraTags = next
  }

  private extraOn(name: string): boolean {
    for (const t of this.extraTags) {
      if (t === name) {
        return true
      }
    }
    return false
  }

  private async submit(): Promise<void> {
    if (!AuthService.requireAuth('create_diary')) {
      this.onRequireAuth()
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.formError = '请填写标题'
      return
    }
    this.submitting = true
    this.formError = ''
    const date = this.formDate.length > 0 ? this.formDate : DiaryEditorSheet.todayIso()
    let cover = this.formCoverKey
    if (cover.length === 0) {
      cover = JournalCatalog.coverForScene(this.formScene)
    }
    const tags = this.buildTags()
    const body = this.formBody.trim()
    const summary = body.length > 80 ? body.substring(0, 80) : body
    try {
      if (this.editId.length > 0) {
        const req = new UpdateDiaryRequest()
        req.title = this.formTitle.trim()
        req.body = body
        req.summary = summary
        req.tags = tags
        req.recordDate = date
        req.coverKey = cover
        req.imageKeys = cover.length > 0 ? [cover] : []
        req.userId = this.currentUsername
        req.kind = this.formMood
        req.category = this.formScene
        const updated = await JournalBizService.updateDiary(this.editId, req)
        if (updated !== undefined) {
          this.onSaved(updated)
          this.onClose()
        } else {
          this.formError = JournalBizService.lastError.length > 0 ? JournalBizService.lastError : '保存失败'
        }
      } else {
        const req = new CreateDiaryRequest()
        req.title = this.formTitle.trim()
        req.body = body
        req.summary = summary
        req.tags = tags
        req.recordDate = date
        req.coverKey = cover
        req.imageKeys = cover.length > 0 ? [cover] : []
        req.userId = this.currentUsername
        req.kind = this.formMood
        req.category = this.formScene
        const created = await JournalBizService.createDiary(req)
        if (created !== undefined) {
          this.onSaved(created)
          this.onClose()
        } else {
          this.formError = JournalBizService.lastError.length > 0 ? JournalBizService.lastError : '保存失败'
        }
      }
    } catch {
      this.formError = '保存失败，请稍后重试'
    }
    this.submitting = false
  }

  @Builder
  MoodChips() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(this.moods, (opt: JournalChoice) => {
        Text(opt.label)
          .fontSize(Theme.type.caption)
          .fontColor(this.formMood === opt.id ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.formMood === opt.id ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
          .margin({ right: 8, bottom: 8 })
          .onClick((): void => { this.formMood = opt.id })
      }, (opt: JournalChoice) => opt.id)
    }
    .width('100%')
  }

  @Builder
  SceneChips() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(this.scenes, (opt: JournalChoice) => {
        Text(opt.label)
          .fontSize(Theme.type.caption)
          .fontColor(this.formScene === opt.id ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.formScene === opt.id ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
          .margin({ right: 8, bottom: 8 })
          .onClick((): void => { this.formScene = opt.id })
      }, (opt: JournalChoice) => `s_${opt.id}`)
    }
    .width('100%')
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onClose() })
        Text(this.editId.length > 0 ? '编辑这一页' : '写一页')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.formError.length > 0) {
        Text(this.formError)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: 6 }) {
            Text('今日笺题')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Text(this.promptText)
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .width('100%')
              .onClick((): void => {
                this.formTitle = this.promptText
              })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.lg)

          Column({ space: 6 }) {
            Text('标题')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.formTitle, placeholder: '给今天起个名字…' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formTitle = v })
          }
          .width('100%')

          AppDatePickerField({
            label: '记录日期',
            value: this.formDate,
            minDaysFromToday: -3650,
            maxDaysFromToday: 0,
            onChange: (v: string) => {
              this.formDate = v
              this.promptText = JournalCatalog.promptForDate(v)
            }
          })

          Column({ space: 6 }) {
            Text('心情')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            this.MoodChips()
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('生活场景')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            this.SceneChips()
          }
          .width('100%')

          if (this.lifeTags.length > 0) {
            Column({ space: 6 }) {
              Text('生活标签')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.lifeTags, (tag: LifeTag) => {
                  Text(tag.name)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.extraOn(tag.name) ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.extraOn(tag.name) ?
                      Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                    .margin({ right: 8, bottom: 8 })
                    .onClick((): void => { this.toggleExtra(tag.name) })
                }, (tag: LifeTag) => tag.id)
              }
              .width('100%')
            }
            .width('100%')
          }

          Column({ space: 6 }) {
            Text('正文')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextArea({ text: this.formBody, placeholder: '写下此刻的心情与故事…' })
              .width('100%')
              .height(140)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formBody = v })
          }
          .width('100%')

          Column({ space: Theme.space.s2 }) {
            Row({ space: Theme.space.s2 }) {
              Text('配图（可选，可从相册选择）')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .layoutWeight(1)
              AppButton({
                label: this.picking ? '选择中…' : '从相册选择',
                variant: 'secondary',
                disabled: this.picking,
                onTap: (): void => { void this.pickPhoto() }
              })
            }
            .width('100%')
            if (this.pickHint.length > 0) {
              Text(this.pickHint)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            if (this.formCoverKey.length > 0) {
              AlbumPhotoTile({ photoKey: this.formCoverKey, tileSize: 96 })
            }
          }
          .width('100%')

          AppButton({
            label: this.submitting ? '保存中…' : '保存这一页',
            disabled: this.submitting,
            onTap: (): void => { void this.submit() }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(25)
  }
}
