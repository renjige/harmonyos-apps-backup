import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppNavBar } from '../design-system/AppNavBar'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { AppTextField } from '../design-system/AppTextField'
import { SportAlbum, SportEvent } from '../../models/SaituSportModels'
import { AppContextService } from '../../services/AppContextService'
import { ImagePathUtil } from '../../services/ImagePathUtil'
import { PhotoPickService } from '../../services/PhotoPickService'
import { SaituSportStore } from '../../services/SaituSportStore'
import { SaituDetailNav } from '../../services/SaituDetailNav'

@Component
export struct SportEventEditor {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('saituSportEditorId') @Watch('onTargetChange') editorId: string = ''
  @StorageLink('saituSportEditorKind') editorKind: string = 'record'
  @StorageLink('saituSportEditorAlbumId') editorAlbumId: string = ''
  @Prop @Watch('onTargetChange') editorSession: number = 0
  onSaved: () => void = () => {}
  @State title: string = ''
  @State eventDate: string = ''
  @State sportType: string = 'mixed'
  @State highlight: string = ''
  @State body: string = ''
  @State tagsInput: string = ''
  @State status: string = 'done'
  @State albums: SportAlbum[] = []
  @State albumId: string = ''
  @State homeName: string = ''
  @State awayName: string = ''
  @State homeScore: string = ''
  @State awayScore: string = ''
  @State watchMode: string = ''
  @State mood: number = 0
  @State images: string[] = []
  @State reviewScene: string = ''
  @State reviewKeyMoment: string = ''
  @State reviewEmotion: string = ''
  @State reviewTakeaway: string = ''
  @State toastText: string = ''
  @State isEdit: boolean = false
  @State kind: string = 'record'
  private editing: SportEvent = new SportEvent()

  aboutToAppear(): void {
    void this.bootstrap()
  }

  onTargetChange(): void {
    void this.bootstrap()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private resetFormFromEvent(found: SportEvent): void {
    this.editing = found
    this.title = found.title
    this.eventDate = found.eventDate
    this.sportType = found.sportType
    this.highlight = found.highlight
    this.body = found.body
    this.tagsInput = found.tags
    this.status = found.status
    this.albumId = found.albumId
    this.kind = found.kind
    this.homeName = found.homeName
    this.awayName = found.awayName
    this.homeScore = found.homeScore
    this.awayScore = found.awayScore
    this.watchMode = found.watchMode
    this.mood = found.mood
    this.images = found.images.slice()
    this.reviewScene = found.reviewScene
    this.reviewKeyMoment = found.reviewKeyMoment
    this.reviewEmotion = found.reviewEmotion
    this.reviewTakeaway = found.reviewTakeaway
    this.isEdit = true
  }

  private resetFormNew(k: string): void {
    this.editing = SportEvent.create(k)
    this.kind = k
    this.title = ''
    this.eventDate = this.editing.eventDate
    this.sportType = 'mixed'
    this.highlight = ''
    this.body = ''
    this.tagsInput = ''
    this.status = this.editing.status
    this.albumId = this.editorAlbumId
    this.homeName = ''
    this.awayName = ''
    this.homeScore = ''
    this.awayScore = ''
    this.watchMode = ''
    this.mood = 0
    this.images = []
    this.reviewScene = ''
    this.reviewKeyMoment = ''
    this.reviewEmotion = ''
    this.reviewTakeaway = ''
    this.isEdit = false
  }

  private async bootstrap(): Promise<void> {
    this.albums = await SaituSportStore.loadAlbums()
    const id = this.editorId
    if (id.length > 0) {
      const found = await SaituSportStore.findEvent(id)
      if (found !== undefined) {
        this.resetFormFromEvent(found)
        return
      }
    }
    const k = this.editorKind.length > 0 ? this.editorKind : 'record'
    this.resetFormNew(k)
  }

  private async pickImages(): Promise<void> {
    const ctx = AppContextService.getContext()
    if (ctx === null) {
      this.showToast('无法打开相册')
      return
    }
    const remain = 6 - this.images.length
    if (remain <= 0) {
      this.showToast('最多 6 张配图')
      return
    }
    const picked = await PhotoPickService.pickImages(ctx, remain)
    if (picked.length === 0) {
      if (PhotoPickService.lastError.length > 0) {
        this.showToast(PhotoPickService.lastError)
      }
      return
    }
    const next: string[] = []
    for (const u of this.images) {
      next.push(u)
    }
    for (const u of picked) {
      next.push(u)
    }
    this.images = next
    this.showToast(`已添加 ${picked.length} 张`)
  }

  private removeImage(idx: number): void {
    const next: string[] = []
    for (let i = 0; i < this.images.length; i++) {
      if (i !== idx) {
        next.push(this.images[i])
      }
    }
    this.images = next
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.showToast('请填写赛事名称')
      return
    }
    this.editing.title = this.title.trim()
    this.editing.eventDate = this.eventDate
    this.editing.sportType = this.sportType
    this.editing.highlight = this.highlight.trim()
    this.editing.body = this.body.trim()
    this.editing.tags = this.tagsInput.trim()
    this.editing.status = this.status
    this.editing.albumId = this.albumId
    this.editing.kind = this.kind
    this.editing.homeName = this.homeName.trim()
    this.editing.awayName = this.awayName.trim()
    this.editing.homeScore = this.homeScore.trim()
    this.editing.awayScore = this.awayScore.trim()
    this.editing.watchMode = this.watchMode
    this.editing.mood = this.mood
    this.editing.images = this.images.slice()
    this.editing.reviewScene = this.reviewScene.trim()
    this.editing.reviewKeyMoment = this.reviewKeyMoment.trim()
    this.editing.reviewEmotion = this.reviewEmotion.trim()
    this.editing.reviewTakeaway = this.reviewTakeaway.trim()
    await SaituSportStore.saveEvent(this.editing)
    SaituDetailNav.closeSportEditor()
    this.onSaved()
  }

  @Builder
  TypeChip(key: string) {
    Text(SportEvent.typeName(key))
      .fontSize(Theme.type.bodyS)
      .fontColor(this.sportType === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.sportType === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.sportType = key })
  }

  @Builder
  StatusChip(key: string, label: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.status === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.status === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.status = key })
  }

  @Builder
  WatchChip(key: string, label: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.watchMode === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.watchMode === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.watchMode = key })
  }

  @Builder
  MoodChip(level: number) {
    Text(`${level}★`)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.mood === level ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.mood === level ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.mood = level })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        AppNavBar({
          title: this.isEdit ? `编辑${this.editing.kindLabel()}` : `新建${this.editing.kindLabel()}`,
          onBack: (): void => SaituDetailNav.closeSportEditor()
        })
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            AppTextField({
              text: this.title,
              placeholder: '赛事名称，如 世界杯决赛观赛',
              onChange: (v: string): void => { this.title = v }
            })
            AppDatePickerField({
              label: '赛事日期',
              value: this.eventDate,
              placeholder: '选择日期',
              minDaysFromToday: -4000,
              maxDaysFromToday: 800,
              onChange: (v: string): void => { this.eventDate = v }
            })
            Text('项目分类')
              .fontSize(Theme.type.overline)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(SportEvent.sportTypes(), (k: string) => {
                this.TypeChip(k)
              }, (k: string) => k)
            }

            if (this.kind !== 'plan') {
              Text('对阵与比分（可选）')
                .fontSize(Theme.type.overline)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
              Row({ space: Theme.space.s2 }) {
                Column() {
                  AppTextField({
                    text: this.homeName,
                    placeholder: '主队/我方',
                    onChange: (v: string): void => { this.homeName = v }
                  })
                }
                .layoutWeight(1)
                AppTextField({
                  text: this.homeScore,
                  placeholder: '分',
                  fieldWidth: 64,
                  inputType: InputType.Number,
                  onChange: (v: string): void => { this.homeScore = v }
                })
              }
              .width('100%')
              Row({ space: Theme.space.s2 }) {
                Column() {
                  AppTextField({
                    text: this.awayName,
                    placeholder: '客队/对手',
                    onChange: (v: string): void => { this.awayName = v }
                  })
                }
                .layoutWeight(1)
                AppTextField({
                  text: this.awayScore,
                  placeholder: '分',
                  fieldWidth: 64,
                  inputType: InputType.Number,
                  onChange: (v: string): void => { this.awayScore = v }
                })
              }
              .width('100%')
              Text('观赛方式')
                .fontSize(Theme.type.overline)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
              Row({ space: Theme.space.s2 }) {
                this.WatchChip('live', '现场')
                this.WatchChip('tv', '转播')
                this.WatchChip('play', '参赛')
              }
              Text('观赛心情')
                .fontSize(Theme.type.overline)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
              Row({ space: Theme.space.s2 }) {
                this.MoodChip(1)
                this.MoodChip(2)
                this.MoodChip(3)
                this.MoodChip(4)
                this.MoodChip(5)
              }
            }

            if (this.kind === 'plan') {
              Text('关注状态')
                .fontSize(Theme.type.overline)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
              Row({ space: Theme.space.s2 }) {
                this.StatusChip('pending', '待关注')
                this.StatusChip('done', '已完成')
                this.StatusChip('reviewed', '已回顾')
              }
            }

            if (this.kind === 'review') {
              Text('结构化复盘')
                .fontSize(Theme.type.overline)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
              TextArea({ text: this.reviewScene, placeholder: '场面与节奏：开局、中段、末段…' })
                .height(72)
                .fontSize(Theme.type.body)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.md)
                .onChange((v: string): void => { this.reviewScene = v })
              TextArea({ text: this.reviewKeyMoment, placeholder: '关键球/节点：进球、失误、转折点…' })
                .height(72)
                .fontSize(Theme.type.body)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.md)
                .onChange((v: string): void => { this.reviewKeyMoment = v })
              TextArea({ text: this.reviewEmotion, placeholder: '情绪曲线：紧张、兴奋、遗憾…' })
                .height(64)
                .fontSize(Theme.type.body)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.md)
                .onChange((v: string): void => { this.reviewEmotion = v })
              TextArea({ text: this.reviewTakeaway, placeholder: '带走一句：下次观赛或训练要注意…' })
                .height(64)
                .fontSize(Theme.type.body)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.md)
                .onChange((v: string): void => { this.reviewTakeaway = v })
            }

            AppTextField({
              text: this.highlight,
              placeholder: this.kind === 'review' ? '一句话评价' : '亮点或关键事件',
              onChange: (v: string): void => { this.highlight = v }
            })
            TextArea({ text: this.body, placeholder: this.kind === 'note' ? '过程观察、战术与个人观点' : '心得、分析或回忆' })
              .height(120)
              .fontSize(Theme.type.body)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string): void => { this.body = v })

            Text('现场配图（可选）')
              .fontSize(Theme.type.overline)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            AppButton({ label: '从相册添加', variant: 'secondary', onTap: (): void => { void this.pickImages() } })
            if (this.images.length > 0) {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.images, (uri: string, idx: number) => {
                  Image(ImagePathUtil.toDisplayUri(uri))
                    .width(88)
                    .height(88)
                    .borderRadius(Theme.radius.sm)
                    .objectFit(ImageFit.Cover)
                    .margin({ right: 8, bottom: 8 })
                    .onClick((): void => this.removeImage(idx))
                }, (uri: string, idx: number) => `${idx}_${uri}`)
              }
            }

            Text('标签')
              .fontSize(Theme.type.overline)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            AppTextField({
              text: this.tagsInput,
              placeholder: '精彩逆转、经典对决…（空格或逗号分隔）',
              onChange: (v: string): void => { this.tagsInput = v }
            })
            if (this.albums.length > 0) {
              Text('收入纪念册（可选）')
                .fontSize(Theme.type.overline)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.albums, (a: SportAlbum) => {
                  Text(a.title)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(this.albumId === a.id ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .backgroundColor(this.albumId === a.id ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { this.albumId = this.albumId === a.id ? '' : a.id })
                }, (a: SportAlbum) => a.id)
              }
            }
            AppButton({ label: this.isEdit ? '保存修改' : '保存', variant: 'primary', onTap: (): void => { void this.save() } })
            Blank().height(Theme.space.s10)
          }
          .padding(Theme.space.pageX)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s8 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
