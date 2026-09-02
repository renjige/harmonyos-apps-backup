import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { LocalPhotoImage } from '../components/album/LocalPhotoImage'
import { DateFormatUtil } from '../components/design-system/DateFormatUtil'
import { FamilyMember, PhotoWrite, ThemeAlbum } from '../models/AlbumModels'
import { AlbumStore } from '../services/AlbumStore'
import { PhotoPickService } from '../services/PhotoPickService'

@Component
export struct PhotoUploadPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onOpen') refreshToken: number = 0
  onToast: (text: string) => void = (text: string) => {}
  onClose: () => void = () => {}

  @State caption: string = ''
  @State location: string = '家庭日常'
  @State memberId: string = ''
  @State albumId: string = ''
  @State takenDate: string = ''
  @State members: FamilyMember[] = []
  @State albums: ThemeAlbum[] = []
  @State pickedUris: string[] = []
  @State uploading: boolean = false
  private uiContext: common.UIAbilityContext | null = null

  aboutToAppear(): void {
    this.resetForm()
  }

  onOpen(): void {
    this.resetForm()
  }

  private resetForm(): void {
    this.caption = ''
    this.location = '家庭日常'
    this.takenDate = DateFormatUtil.formatDate(new Date())
    this.pickedUris = []
    this.uploading = false
    this.members = AlbumStore.members()
    this.albums = AlbumStore.albums()
    if (this.members.length > 0) {
      this.memberId = this.members[0].id
    }
    if (this.albums.length > 0) {
      this.albumId = this.albums[0].id
    }
  }

  private uploaderName(): string {
    const m = AlbumStore.findMember(this.memberId)
    if (m !== null) {
      return m.name
    }
    return AlbumStore.settings().displayName.length > 0 ? AlbumStore.settings().displayName : '我'
  }

  private takenAt(): number {
    if (this.takenDate.length === 0) {
      return Date.now()
    }
    return DateFormatUtil.parseDate(this.takenDate).getTime()
  }

  private async pickPhotos(): Promise<void> {
    if (this.uiContext === null) {
      this.onToast('无法打开相册，请稍后再试')
      return
    }
    const uris = await PhotoPickService.pickImages(this.uiContext, 9)
    if (uris.length === 0) {
      const err = PhotoPickService.lastError
      this.onToast(err.length > 0 ? err : '未选择照片')
      return
    }
    this.pickedUris = uris
    this.onToast(`已选择 ${uris.length} 张，保存后会按人物/地点自动分册`)
  }

  private async submit(): Promise<void> {
    if (this.pickedUris.length === 0) {
      this.onToast('请先选择照片')
      return
    }
    this.uploading = true
    const write = new PhotoWrite()
    write.caption = this.caption
    write.location = this.location.length > 0 ? this.location : '家庭日常'
    write.memberId = this.memberId
    write.takenAt = this.takenAt()
    write.albumId = this.albumId
    write.favorited = false
    const count = await AlbumStore.addPhotos(this.pickedUris, write, this.uploaderName())
    this.uploading = false
    if (count === 0) {
      this.onToast('保存失败，请稍后再试')
      return
    }
    this.onToast(`已保存 ${count} 张，已整理到分册`)
    this.onClose()
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width(48)
          .height(48)
          .textAlign(TextAlign.Center)
          .onClick((): void => { this.onClose() })
        Text('上传照片')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text(' ')
          .width(48)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column() {
          AppButton({ label: '从相册选择', variant: 'secondary', onTap: (): void => { void this.pickPhotos() } })

          if (this.pickedUris.length > 0) {
            Text(`预览 ${this.pickedUris.length} 张 · 保存后出现在首页与相册`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
              .margin({ top: Theme.space.s3, bottom: Theme.space.s2 })
            GridRow({ columns: 3, gutter: 4 }) {
              ForEach(this.pickedUris, (uri: string) => {
                GridCol() {
                  LocalPhotoImage({ uri: uri, squareFill: true, radius: Theme.radius.sm })
                }
              }, (uri: string) => uri)
            }
            .width('100%')
          }

          Text('简短描述')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
            .margin({ top: Theme.space.s5, bottom: Theme.space.s2 })
          TextInput({ text: this.caption, placeholder: '记录这一刻…' })
            .onChange((v: string) => { this.caption = v })

          Text('地点（用于地点分册）')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
            .margin({ top: Theme.space.s4, bottom: Theme.space.s2 })
          TextInput({ text: this.location, placeholder: '如：客厅、公园' })
            .onChange((v: string) => { this.location = v })

          AppDatePickerField({
            label: '拍摄日期（用于时间分册与往年的今天）',
            value: this.takenDate,
            placeholder: '选择日期',
            minDaysFromToday: -3650,
            maxDaysFromToday: 0,
            onChange: (v: string) => { this.takenDate = v }
          })
            .margin({ top: Theme.space.s4 })

          Text('上传成员')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
            .margin({ top: Theme.space.s4, bottom: Theme.space.s2 })
          Row({ space: Theme.space.s2 }) {
            ForEach(this.members, (m: FamilyMember) => {
              Text(m.name)
                .fontSize(Theme.type.caption)
                .fontColor(this.memberId === m.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .height(48)
                .padding({ left: 12, right: 12 })
                .textAlign(TextAlign.Center)
                .backgroundColor(this.memberId === m.id ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.memberId = m.id })
            }, (m: FamilyMember) => m.id)
          }
          .width('100%')

          Text('归入主题册')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
            .margin({ top: Theme.space.s4, bottom: Theme.space.s2 })
          Row({ space: Theme.space.s2 }) {
            ForEach(this.albums, (a: ThemeAlbum) => {
              Text(a.title)
                .fontSize(Theme.type.caption)
                .fontColor(this.albumId === a.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .height(48)
                .padding({ left: 12, right: 12 })
                .textAlign(TextAlign.Center)
                .backgroundColor(this.albumId === a.id ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.albumId = a.id })
            }, (a: ThemeAlbum) => a.id)
          }
          .width('100%')

          AppButton({
            label: this.uploading ? '保存中…' : '保存到家庭册',
            disabled: this.uploading,
            onTap: (): void => { void this.submit() }
          })
            .margin({ top: Theme.space.s8 })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .onAppear((): void => {
      const host = this.getUIContext().getHostContext()
      if (host !== undefined) {
        this.uiContext = host as common.UIAbilityContext
      }
    })
  }
}
