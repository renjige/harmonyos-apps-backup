import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { DiaryWriteEditor } from '../components/diary/DiaryWriteEditor'
import { DiaryEntry } from '../models/DiaryModels'
import { DateHelper } from '../services/DateHelper'
import { DiaryStore } from '../services/DiaryStore'
import { PhotoPickService } from '../services/PhotoPickService'

@Component
export struct WritePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State seedBody: string = ''
  @State seedVersion: number = 0
  @State imagePath: string = ''
  @State entryId: string = ''
  @State dateKey: string = DateHelper.todayKey()
  @State saving: boolean = false
  @State toastText: string = ''
  @State refreshToken: number = 0
  @Prop reloadToken: number = 0
  private saveTimer: number = -1
  private liveBody: string = ''
  private uiContext: common.UIAbilityContext | null = null

  aboutToAppear(): void {
    void this.bootstrap()
  }

  aboutToDisappear(): void {
    if (this.saveTimer >= 0) {
      clearTimeout(this.saveTimer)
      this.saveTimer = -1
    }
    const body = this.currentBody()
    if (body.trim().length > 0 || this.imagePath.length > 0) {
      void this.persist(true, body)
    }
  }

  private currentBody(): string {
    return this.liveBody.length > 0 ? this.liveBody : this.seedBody
  }

  private onReload(): void {
    if (this.reloadToken !== this.refreshToken) {
      this.refreshToken = this.reloadToken
      void this.bootstrap()
    }
  }

  private async bootstrap(): Promise<void> {
    this.dateKey = DateHelper.todayKey()
    this.liveBody = ''
    const existing = await DiaryStore.findTodayEntry()
    if (existing !== undefined) {
      this.entryId = existing.id
      this.seedBody = existing.body
      this.imagePath = existing.imagePath
      this.seedVersion++
      return
    }
    const draft = await DiaryStore.loadDraft(this.dateKey)
    this.seedBody = draft
    this.imagePath = ''
    this.seedVersion++
  }

  private onDraftChange(text: string): void {
    this.liveBody = text
    this.scheduleSave()
  }

  private scheduleSave(): void {
    if (this.saveTimer >= 0) {
      clearTimeout(this.saveTimer)
    }
    this.saveTimer = setTimeout((): void => {
      this.saveTimer = -1
      const body = this.currentBody()
      void DiaryStore.saveDraft(this.dateKey, body)
    }, 2000)
  }

  private async persist(silent: boolean, bodyOverride?: string): Promise<void> {
    const body = bodyOverride ?? this.currentBody()
    if (body.trim().length === 0 && this.imagePath.length === 0) {
      await DiaryStore.saveDraft(this.dateKey, body)
      return
    }
    this.saving = true
    let entry: DiaryEntry
    if (this.entryId.length > 0) {
      const found = await DiaryStore.findById(this.entryId)
      entry = found ?? DiaryEntry.createNew(this.dateKey)
    } else {
      entry = DiaryEntry.createNew(this.dateKey)
      this.entryId = entry.id
    }
    entry.body = body
    entry.imagePath = this.imagePath
    entry.dateKey = this.dateKey
    await DiaryStore.saveEntry(entry)
    this.seedBody = body
    this.liveBody = body
    this.saving = false
    if (!silent) {
      this.showToast('已保存')
    }
  }

  private async pickImage(): Promise<void> {
    if (this.uiContext === null) {
      return
    }
    const uri = await PhotoPickService.pickOneImage(this.uiContext)
    if (uri.length > 0) {
      this.imagePath = uri
      void this.persist(true)
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  build() {
    Stack() {
      Column() {
        Image($r('app.media.hero_paper_bg'))
          .width('100%')
          .height(96)
          .objectFit(ImageFit.Cover)
          .borderRadius({ bottomLeft: Theme.radius.lg, bottomRight: Theme.radius.lg })

        Row() {
          Column({ space: 2 }) {
            Text(DateHelper.displayDate(this.dateKey))
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(DateHelper.displayWeekday(this.dateKey))
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          if (this.saving) {
            Text('保存中…')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          }
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s3,
          bottom: Theme.space.s2
        })

        DiaryWriteEditor({
          seedBody: this.seedBody,
          seedVersion: this.seedVersion,
          onDraftChange: (text: string): void => { this.onDraftChange(text) },
          onFormatToast: (msg: string): void => { this.showToast(msg) }
        })
          .layoutWeight(1)
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.imagePath.length > 0) {
          Stack({ alignContent: Alignment.TopEnd }) {
            Image(this.imagePath)
              .width('100%')
              .height(100)
              .borderRadius(Theme.radius.md)
              .objectFit(ImageFit.Cover)
            Row() {
              AppIcon({
                name: 'close',
                iconSize: Theme.icon.md,
                color: Theme.colors().textOnInverse
              })
            }
            .padding(8)
            .backgroundColor('rgba(0,0,0,0.35)')
            .borderRadius(Theme.radius.pill)
            .onClick((): void => {
              this.imagePath = ''
              void this.persist(true)
            })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
        }

        Row({ space: Theme.space.s3 }) {
          AppButton({
            label: '插入图片',
            variant: 'secondary',
            onTap: (): void => { void this.pickImage() }
          }).layoutWeight(1)
          AppButton({
            label: '保存',
            variant: 'primary',
            onTap: (): void => { void this.persist(false) }
          }).layoutWeight(1)
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s2,
          bottom: Theme.space.s3
        })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
        .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '20%', y: 48 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .onAppear((): void => {
      this.onReload()
      const host = this.getUIContext().getHostContext()
      if (host !== undefined) {
        this.uiContext = host as common.UIAbilityContext
      }
    })
  }
}
