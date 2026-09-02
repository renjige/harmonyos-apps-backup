import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { LocalPhotoImage } from '../album/LocalPhotoImage'
import { DateFormatUtil } from '../design-system/DateFormatUtil'
import { FamilyMember, FamilyPhoto, PhotoWrite, ThemeAlbum } from '../../models/AlbumModels'
import { AlbumStore } from '../../services/AlbumStore'

@Component
export struct PhotoDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop photoId: string = ''
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onToast: (text: string) => void = (text: string) => {}
  onBack: () => void = () => {}

  @State photo: FamilyPhoto = new FamilyPhoto()
  @State caption: string = ''
  @State location: string = ''
  @State memberId: string = ''
  @State albumId: string = ''
  @State takenDate: string = ''
  @State members: FamilyMember[] = []
  @State albums: ThemeAlbum[] = []
  @State confirmDelete: boolean = false

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshChange(): void {
    this.reload()
  }

  private reload(): void {
    this.members = AlbumStore.members()
    this.albums = AlbumStore.albums()
    const found = AlbumStore.findPhoto(this.photoId)
    if (found !== null) {
      this.photo = found
      this.caption = found.caption
      this.location = found.location
      this.memberId = found.memberId
      this.albumId = found.albumId
      this.takenDate = found.takenAt > 0 ? DateFormatUtil.formatDate(new Date(found.takenAt)) : ''
    }
  }

  private async handleSave(): Promise<void> {
    const write = new PhotoWrite()
    write.caption = this.caption
    write.location = this.location
    write.memberId = this.memberId
    write.albumId = this.albumId
    write.favorited = this.photo.favorited
    write.takenAt = this.takenDate.length > 0 ? DateFormatUtil.parseDate(this.takenDate).getTime() : this.photo.takenAt
    const ok = await AlbumStore.updatePhoto(this.photo.id, write)
    if (!ok) {
      this.onToast('保存失败')
      return
    }
    this.reload()
    this.onToast('照片信息已更新，分册会同步整理')
  }

  private async handleFavorite(): Promise<void> {
    const ok = await AlbumStore.toggleFavorite(this.photo.id)
    if (!ok) {
      this.onToast('操作失败')
      return
    }
    this.reload()
    this.onToast(this.photo.favorited ? '已加入珍藏' : '已取消珍藏')
  }

  private async handleDelete(): Promise<void> {
    const ok = await AlbumStore.deletePhoto(this.photo.id)
    if (!ok) {
      this.onToast('删除失败，请稍后再试')
      return
    }
    this.onToast('照片已删除')
    this.onBack()
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
          .onClick((): void => { this.onBack() })
        Text('照片详情')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Scroll() {
        Column() {
          LocalPhotoImage({ uri: this.photo.uri, stretch: true, tileH: 240, radius: Theme.radius.card })

          Column() {
            TextInput({ text: this.caption, placeholder: '添加描述' })
              .onChange((v: string) => { this.caption = v })
            TextInput({ text: this.location, placeholder: '地点，如客厅' })
              .onChange((v: string) => { this.location = v })
              .margin({ top: Theme.space.s3 })
            AppDatePickerField({
              label: '拍摄日期',
              value: this.takenDate,
              placeholder: '选择日期',
              minDaysFromToday: -3650,
              maxDaysFromToday: 0,
              onChange: (v: string) => { this.takenDate = v }
            })
              .margin({ top: Theme.space.s3 })

            Text('人物')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
              .margin({ top: Theme.space.s3, bottom: Theme.space.s2 })
            Row({ space: Theme.space.s2 }) {
              ForEach(this.members, (m: FamilyMember) => {
                Text(m.name)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.memberId === m.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .height(40)
                  .padding({ left: 10, right: 10 })
                  .backgroundColor(this.memberId === m.id ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.memberId = m.id })
              }, (m: FamilyMember) => m.id)
            }
            .width('100%')

            Text('主题册')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
              .margin({ top: Theme.space.s3, bottom: Theme.space.s2 })
            Row({ space: Theme.space.s2 }) {
              ForEach(this.albums, (a: ThemeAlbum) => {
                Text(a.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.albumId === a.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .height(40)
                  .padding({ left: 10, right: 10 })
                  .backgroundColor(this.albumId === a.id ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.albumId = a.id })
              }, (a: ThemeAlbum) => a.id)
            }
            .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)
          .margin({ top: Theme.space.s4 })

          AppButton({ label: '保存修改', onTap: (): void => { void this.handleSave() } })
            .margin({ top: Theme.space.s5 })
          AppButton({
            label: this.photo.favorited ? '取消珍藏' : '加入珍藏',
            variant: 'secondary',
            onTap: (): void => { void this.handleFavorite() }
          })
            .margin({ top: Theme.space.s3 })
          AppButton({
            label: this.confirmDelete ? '确认删除这张照片？' : '删除照片',
            variant: 'secondary',
            onTap: (): void => {
              if (!this.confirmDelete) {
                this.confirmDelete = true
                return
              }
              void this.handleDelete()
            }
          })
            .margin({ top: Theme.space.s3 })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
