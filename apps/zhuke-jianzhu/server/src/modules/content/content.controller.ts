import { Body, Controller, Delete, Get, Param, Post, Put, Query } from '@nestjs/common';
import { ok } from '../../common/api-response';
import { ContentPersistenceService } from '../../database/content-persistence.service';
import { contentStore } from './content.service';

/** 公开内容接口 + 后台管理接口 */
@Controller()
export class ContentController {
  constructor(private readonly persistence: ContentPersistenceService) {}

  private flush(): void {
    void this.persistence.persistStore(contentStore);
  }
  @Get('content/company')
  company() {
    return ok(contentStore.company);
  }

  @Get('content/contact')
  contact() {
    return ok(contentStore.contact);
  }

  @Get('content/businesses')
  businesses() {
    return ok(contentStore.businesses);
  }

  @Get('content/businesses/:id')
  businessDetail(@Param('id') id: string) {
    return ok(contentStore.businesses.find((b) => b.id === id) ?? null);
  }

  @Get('content/honors')
  honors() {
    return ok(contentStore.honors);
  }

  @Get('content/honors/:id')
  honorDetail(@Param('id') id: string) {
    return ok(contentStore.honors.find((h) => h.id === id) ?? null);
  }

  @Get('content/notifications')
  notifications() {
    return ok(contentStore.notifications);
  }

  @Get('content/banners')
  banners() {
    return ok(contentStore.banners.filter((b) => b.enabled).sort((a, b) => a.sortOrder - b.sortOrder));
  }

  @Get('content/projects')
  projects(@Query('category') category = 'all', @Query('featured') featured?: string) {
    let list = [...contentStore.projects];
    if (category !== 'all') list = list.filter((p) => p.category === category);
    if (featured === 'true') list = list.filter((p) => p.featured);
    return ok({ list, total: list.length });
  }

  @Get('content/projects/:id')
  projectDetail(@Param('id') id: string) {
    const row = contentStore.projects.find((p) => p.id === id);
    return ok(row ?? null);
  }

  @Get('content/news')
  news(@Query('category') category = 'all') {
    let list = [...contentStore.news];
    if (category !== 'all') list = list.filter((n) => n.category === category);
    return ok({ list, total: list.length });
  }

  @Get('content/news/:id')
  newsDetail(@Param('id') id: string) {
    return ok(contentStore.news.find((n) => n.id === id) ?? null);
  }

  @Get('content/certificates')
  certificates() {
    return ok(contentStore.certificates);
  }

  @Get('content/jobs')
  jobs() {
    return ok(contentStore.jobs);
  }

  @Get('content/jobs/:id')
  jobDetail(@Param('id') id: string) {
    return ok(contentStore.jobs.find((j) => j.id === id) ?? null);
  }

  @Post('content/messages')
  submitMessage(@Body() body: { name?: string; phone?: string; content?: string; type?: string }) {
    const row = {
      id: crypto.randomUUID(),
      name: body.name || '',
      phone: body.phone || '',
      content: body.content || '',
      type: (body.type === 'feedback' ? 'feedback' : 'contact') as 'contact' | 'feedback',
      status: 'pending' as const,
      createdAt: new Date().toISOString(),
    };
    contentStore.guestMessages.unshift(row);
    this.flush();
    return ok(row);
  }

  @Post('content/feedback')
  submitFeedback(@Body() body: { content?: string; contact?: string }) {
    const row = {
      id: crypto.randomUUID(),
      name: 'App反馈',
      phone: body.contact || '',
      content: body.content || '',
      type: 'feedback' as const,
      status: 'pending' as const,
      createdAt: new Date().toISOString(),
    };
    contentStore.guestMessages.unshift(row);
    this.flush();
    return ok(row);
  }

  // —— 后台管理 ——
  @Get('admin/banners')
  adminBanners() {
    return ok(contentStore.banners);
  }

  @Post('admin/banners')
  createBanner(@Body() body: Record<string, unknown>) {
    const row = {
      id: crypto.randomUUID(),
      title: String(body.title || ''),
      subtitle: String(body.subtitle || ''),
      imageKey: String(body.imageKey || 'banner_landmark'),
      sortOrder: Number(body.sortOrder || contentStore.banners.length + 1),
      enabled: body.enabled !== false,
    };
    contentStore.banners.push(row);
    this.flush();
    return ok(row);
  }

  @Put('admin/banners/:id')
  updateBanner(@Param('id') id: string, @Body() body: Record<string, unknown>) {
    const idx = contentStore.banners.findIndex((b) => b.id === id);
    if (idx < 0) return ok(null);
    contentStore.banners[idx] = { ...contentStore.banners[idx], ...body, id };
    this.flush();
    return ok(contentStore.banners[idx]);
  }

  @Delete('admin/banners/:id')
  deleteBanner(@Param('id') id: string) {
    contentStore.banners = contentStore.banners.filter((b) => b.id !== id);
    this.flush();
    return ok({ deleted: id });
  }

  @Get('admin/projects')
  adminProjects() {
    return ok(contentStore.projects);
  }

  @Post('admin/projects')
  createProject(@Body() body: Record<string, unknown>) {
    const row = {
      id: crypto.randomUUID(),
      title: String(body.title || ''),
      category: String(body.category || 'building'),
      coverKey: String(body.coverKey || 'project_building'),
      summary: String(body.summary || ''),
      location: String(body.location || ''),
      completedAt: String(body.completedAt || ''),
      description: String(body.description || ''),
      featured: Boolean(body.featured),
    };
    contentStore.projects.unshift(row);
    this.flush();
    return ok(row);
  }

  @Put('admin/projects/:id')
  updateProject(@Param('id') id: string, @Body() body: Record<string, unknown>) {
    const idx = contentStore.projects.findIndex((p) => p.id === id);
    if (idx < 0) return ok(null);
    contentStore.projects[idx] = { ...contentStore.projects[idx], ...body, id } as typeof contentStore.projects[0];
    this.flush();
    return ok(contentStore.projects[idx]);
  }

  @Delete('admin/projects/:id')
  deleteProject(@Param('id') id: string) {
    contentStore.projects = contentStore.projects.filter((p) => p.id !== id);
    this.flush();
    return ok({ deleted: id });
  }

  @Get('admin/news')
  adminNews() {
    return ok(contentStore.news);
  }

  @Post('admin/news')
  createNews(@Body() body: Record<string, unknown>) {
    const row = {
      id: crypto.randomUUID(),
      title: String(body.title || ''),
      category: String(body.category || 'company'),
      summary: String(body.summary || ''),
      content: String(body.content || ''),
      publishedAt: String(body.publishedAt || new Date().toISOString().slice(0, 10)),
      coverKey: String(body.coverKey || 'news_cover'),
    };
    contentStore.news.unshift(row);
    this.flush();
    return ok(row);
  }

  @Put('admin/news/:id')
  updateNews(@Param('id') id: string, @Body() body: Record<string, unknown>) {
    const idx = contentStore.news.findIndex((n) => n.id === id);
    if (idx < 0) return ok(null);
    contentStore.news[idx] = { ...contentStore.news[idx], ...body, id } as typeof contentStore.news[0];
    this.flush();
    return ok(contentStore.news[idx]);
  }

  @Delete('admin/news/:id')
  deleteNews(@Param('id') id: string) {
    contentStore.news = contentStore.news.filter((n) => n.id !== id);
    this.flush();
    return ok({ deleted: id });
  }

  @Get('admin/certificates')
  adminCertificates() {
    return ok(contentStore.certificates);
  }

  @Post('admin/certificates')
  createCertificate(@Body() body: Record<string, unknown>) {
    const row = {
      id: crypto.randomUUID(),
      name: String(body.name || ''),
      issuer: String(body.issuer || ''),
      validUntil: String(body.validUntil || ''),
      coverKey: String(body.coverKey || 'cert_honor'),
    };
    contentStore.certificates.push(row);
    this.flush();
    return ok(row);
  }

  @Get('admin/jobs')
  adminJobs() {
    return ok(contentStore.jobs);
  }

  @Post('admin/jobs')
  createJob(@Body() body: Record<string, unknown>) {
    const row = {
      id: crypto.randomUUID(),
      title: String(body.title || ''),
      department: String(body.department || ''),
      location: String(body.location || ''),
      salary: String(body.salary || ''),
      experience: String(body.experience || ''),
      education: String(body.education || ''),
      publishedAt: String(body.publishedAt || new Date().toISOString().slice(0, 10)),
      contactPhone: String(body.contactPhone || ''),
      contactEmail: String(body.contactEmail || ''),
      requirements: Array.isArray(body.requirements) ? body.requirements.map(String) : [],
      responsibilities: Array.isArray(body.responsibilities) ? body.responsibilities.map(String) : [],
    };
    contentStore.jobs.unshift(row);
    this.flush();
    return ok(row);
  }

  @Get('admin/honors')
  adminHonors() {
    return ok(contentStore.honors);
  }

  @Post('admin/honors')
  createHonor(@Body() body: Record<string, unknown>) {
    const row = {
      id: crypto.randomUUID(),
      title: String(body.title || ''),
      year: String(body.year || ''),
      issuer: String(body.issuer || ''),
      description: String(body.description || ''),
      imageKey: String(body.imageKey || 'honor_trophy'),
    };
    contentStore.honors.push(row);
    return ok(row);
  }

  @Get('admin/notifications')
  adminNotifications() {
    return ok(contentStore.notifications);
  }

  @Post('admin/notifications')
  createNotification(@Body() body: Record<string, unknown>) {
    const row = {
      id: crypto.randomUUID(),
      title: String(body.title || ''),
      body: String(body.body || ''),
      fullBody: String(body.fullBody || body.body || ''),
      createdAt: String(body.createdAt || new Date().toISOString().slice(0, 10)),
    };
    contentStore.notifications.unshift(row);
    return ok(row);
  }

  @Get('admin/messages')
  adminMessages() {
    return ok(contentStore.guestMessages);
  }

  @Put('admin/messages/:id')
  handleMessage(@Param('id') id: string, @Body() body: { status?: string }) {
    const row = contentStore.guestMessages.find((m) => m.id === id);
    if (row && body.status === 'handled') row.status = 'handled';
    this.flush();
    return ok(row ?? null);
  }
}
