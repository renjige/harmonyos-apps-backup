import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { AuthService } from '../../services/AuthService'
import { CampBizService } from '../../services/CampBizService'
import { CampDetailNav } from '../../services/CampDetailNav'
import { CampMedia } from '../../services/CampMedia'
import { CampWriteRequest, CatalogItem } from '../../models/CampModels'
import { FavoriteService } from '../../services/FavoriteService'
import { LearningProgressService } from '../../services/LearningProgressService'
import { DetailShell } from './DetailShell'

@Component
export struct GuideDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onIdChange') itemId: string = ''
  @Prop @Watch('onIdChange') refreshToken: number = 0
  @StorageLink('favoriteTick') favoriteTick: number = 0
  @State item: CatalogItem | undefined = undefined
  @State comments: CatalogItem[] = []
  @State loading: boolean = true
  @State liked: boolean = false
  @State likeN: number = 0
  @State commentText: string = ''
  @State learned: boolean = false
  @State favorited: boolean = false
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await CampBizService.findGuide(this.itemId)
    this.likeN = this.item !== undefined ? this.item.likeCount : 0
    this.comments = await CampBizService.loadComments(this.itemId)
    this.learned = LearningProgressService.isLearned(this.itemId)
    this.favorited = FavoriteService.isFavorite(this.itemId)
    this.loading = false
  }

  private async markLearned(): Promise<void> {
    await LearningProgressService.markLearned(this.itemId)
    this.learned = true
  }

  private async toggleFavorite(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    const cover = this.item.coverKey.length > 0 ? this.item.coverKey : 'guide_tent'
    const nowFav = await FavoriteService.toggle(this.item.id, 'guide', this.item.title, cover)
    this.favorited = nowFav
  }

  private like(): void {
    if (this.liked) {
      return
    }
    this.liked = true
    this.likeN += 1
  }

  private async sendComment(): Promise<void> {
    if (!AuthService.requireAuth('publish_guide')) {
      this.onRequireAuth()
      return
    }
    if (this.commentText.trim().length === 0) {
      return
    }
    const req = new CampWriteRequest()
    req.title = '评论'
    req.body = this.commentText.trim()
    req.campId = this.itemId
    const ok = await CampBizService.create('comments', req)
    if (ok) {
      this.commentText = ''
      this.comments = await CampBizService.loadComments(this.itemId)
    }
  }

  build() {
    if (this.loading) {
      Column() {
        AppLoading({ label: '打开课程' })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    } else if (this.item === undefined) {
      DetailShell({ title: '课程', onClose: () => CampDetailNav.close() }) {
        AppEmpty({ title: '课程不存在', actionLabel: '返回', onAction: () => CampDetailNav.close() })
      }
    } else {
      this.DetailBody()
    }
  }

  @Builder
  DetailBody() {
    DetailShell({ title: this.item !== undefined ? this.item.title : '课程', onClose: () => CampDetailNav.close() }) {
      Column({ space: Theme.space.s5 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(CampMedia.resource(this.item !== undefined ? this.item.coverKey : 'guide_tent'))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(100)
            .linearGradient({
              angle: 180,
              colors: [['rgba(22,51,24,0)', 0.0], ['rgba(22,51,24,0.75)', 1.0]]
            })
          Text(this.item !== undefined ? this.item.title : '')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor('#F5F0E8')
            .padding(16)
        }
        .width('100%')
        .height(220)
        .clip(true)
        .borderRadius(Theme.radius.card)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column({ space: 8 }) {
          Text(`${this.item !== undefined ? this.item.readMinutes : 0} 分钟 · ${this.item !== undefined && this.item.scene.length > 0 ? this.item.scene : '露营课程'} · ${this.likeN} 人觉得有用`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
          Text(this.item !== undefined ? this.item.summary : '')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.card)

        Text(this.item !== undefined ? this.item.body : '')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column({ space: 10 }) {
          AppButton({
            label: this.learned ? '已标记学完' : '标记已学',
            onTap: (): void => { void this.markLearned() }
          })
          AppButton({
            label: this.favorited ? '已收藏' : '收藏课程',
            variant: 'secondary',
            onTap: (): void => { void this.toggleFavorite() }
          })
          AppButton({
            label: this.liked ? '已点赞' : '点赞这篇课程',
            variant: 'ghost',
            onTap: () => this.like()
          })
          TextInput({ text: this.commentText, placeholder: '写下你的学习心得或补充' })
            .onChange((v: string) => { this.commentText = v })
          AppButton({
            label: '发表评论',
            variant: 'ghost',
            onTap: (): void => { void this.sendComment() }
          })
          ForEach(this.comments, (c: CatalogItem) => {
            Text(`${c.authorName.length > 0 ? c.authorName : '学员'}：${c.body}`)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }, (c: CatalogItem) => c.id)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
  }
}
