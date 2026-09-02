import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AlbumPhotoTile } from '../components/journal/AlbumPhotoGrid'
import { LifePageShell } from '../components/life/LifePageShell'
import { CreateAlbumRequest, JournalItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { LifeHubNav } from '../services/LifeHubNav'
import { AuthService } from '../services/AuthService'

class PhotoDayGroup {
  date: string = ''
  keys: string[] = []
}

@Component
export struct PhotoTimelinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  onRequireAuth: () => void = () => {}
  @State groups: PhotoDayGroup[] = []
  @State toastText: string = ''
  @State creating: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    const groups: PhotoDayGroup[] = []
    if (AuthService.isLoggedIn()) {
      const diaries = await JournalBizService.cachedDiaries(this.currentUsername)
      for (const d of diaries) {
        const keys = JournalItem.displayPhotoKeys(d)
        if (keys.length === 0) {
          continue
        }
        const date = d.recordDate.length >= 10 ? d.recordDate.substring(0, 10) : '未标注日期'
        this.mergeGroup(groups, date, keys)
      }
      const albums = await JournalBizService.loadMyAlbums(this.currentUsername)
      for (const a of albums) {
        const keys = JournalItem.displayPhotoKeys(a)
        const date = a.createdAt.length >= 10 ? a.createdAt.substring(0, 10) :
          (a.recordDate.length >= 10 ? a.recordDate.substring(0, 10) : '相册')
        this.mergeGroup(groups, date, keys)
      }
    }
    this.groups = groups
  }

  private mergeGroup(groups: PhotoDayGroup[], date: string, keys: string[]): void {
    let target: PhotoDayGroup | undefined = undefined
    for (const g of groups) {
      if (g.date === date) {
        target = g
      }
    }
    if (target === undefined) {
      target = new PhotoDayGroup()
      target.date = date
      groups.push(target)
    }
    for (const k of keys) {
      let exists = false
      for (const old of target.keys) {
        if (old === k) {
          exists = true
        }
      }
      if (!exists) {
        target.keys.push(k)
      }
    }
  }

  private async albumFromDay(g: PhotoDayGroup): Promise<void> {
    if (!AuthService.requireAuth('create_album')) {
      this.onRequireAuth()
      return
    }
    if (g.keys.length === 0 || this.creating) {
      return
    }
    this.creating = true
    const req = new CreateAlbumRequest()
    req.title = `${g.date} 生活相册`
    req.description = '由照片时光册按日期整理生成'
    req.coverKey = g.keys[0]
    req.imageKeys = g.keys
    req.userId = this.currentUsername
    const created = await JournalBizService.createAlbum(req)
    this.creating = false
    if (created !== undefined) {
      this.showToast('已创建个人生活相册')
      JournalDetailNav.openAlbum(created.id)
    } else {
      this.showToast(JournalBizService.lastError.length > 0 ? JournalBizService.lastError : '创建失败')
    }
  }

  build() {
    Stack() {
      LifePageShell({
        title: '照片时光册',
        subtitle: '按日期整理 · 一键生成相册',
        onClose: (): void => { LifeHubNav.backOrClose() },
        body: () => { this.Body() }
      })
      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      if (this.groups.length === 0) {
        AppEmpty({
          title: '还没有可整理的照片',
          description: '在写一页或相册中加入生活照片后，将按日期自动归集'
        })
      } else {
        ForEach(this.groups, (g: PhotoDayGroup) => {
          Column({ space: Theme.space.s3 }) {
            Text(`${g.date} · ${g.keys.length} 张`)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(g.keys, (k: string) => {
                AlbumPhotoTile({ photoKey: k, tileSize: 96 })
              }, (k: string) => `${g.date}_${k}`)
            }
            .width('100%')
            AppButton({
              label: this.creating ? '创建中…' : '生成这一天的相册',
              variant: 'secondary',
              disabled: this.creating,
              onTap: (): void => { void this.albumFromDay(g) }
            })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .border({ width: 1, color: Theme.colors().strokeHairline })
        }, (g: PhotoDayGroup) => g.date)
      }
    }
    .width('100%')
  }
}
